require 'sinatra/base'
require 'sinatra/namespace'
require 'active_record'
require 'json'

module V2
  class ApplicationController < Sinatra::Base
    register Sinatra::Namespace

    set :show_exceptions, false

    helpers do
      def protected!
        return if authorized?
        respond_with_unauthorized
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)

        if @auth.provided? && @auth.basic? && @auth.credentials
          username,password = @auth.credentials
          user = User.find_by(username: username)
          set_user_id_param(user.id) if user

          user && user.authenticate(password)
        end
      end

      def format_response(response, root)
        preferred_format == 'xml' ? response.to_xml(root: root) : {"#{root}": response}.to_json
      end

      def respond_with_unauthorized
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, format_response({error: I18n.t(:error_401)}, 'errors')
      end

      def respond_with_unacceptable
        halt 406, format_response({error: I18n.t(:error_unsupported_lang)}, 'errors')
      end

      def parse_request_body(request_body)
        preferred_format == 'xml' ? Hash.from_xml(request_body) : JSON.parse(request_body)
      end

      def preferred_format
        preferred_accept_header.split('+').last
      end

      def preferred_accept_header
        request.accept.first.to_s
      end

      def set_pagination_header(resource)
        page = {}
        page[:first] = 1 if resource.total_pages > 1 && !resource.first_page?
        page[:last] = resource.total_pages if resource.total_pages > 1 && !resource.last_page?
        page[:next] = resource.current_page + 1 unless resource.last_page?
        page[:prev] = resource.current_page - 1 unless resource.first_page?

        http_scheme = request.env['rack.url_scheme']
        host = request.env['HTTP_HOST']
        relative_path = request.env['REQUEST_PATH']
        full_path = "#{http_scheme}://#{host}#{relative_path}"
        pagination_links = []

        page.each do |key, value|
          pagination_links << "<#{full_path}?page=#{value}>; rel=\"#{key}\""
        end

        headers['Link'] = pagination_links.join(', ')
      end

      def set_locale
        locale = env.http_accept_language.preferred_language_from(I18n.available_locales)

        locale.nil? ? respond_with_unacceptable : I18n.locale = locale
      end
    end

    before do
      set_locale
    end

    error ActiveRecord::RecordNotFound do
      status 404
      format_response({error: I18n.t(:error_404)}, 'errors')
    end
  end
end

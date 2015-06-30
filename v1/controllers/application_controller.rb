require 'sinatra/base'
require 'sinatra/namespace'
require 'active_record'
require 'json'

module V1
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
        halt 401, format_response({error: 'Not authorized'}, 'errors')
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
    end

    error ActiveRecord::RecordNotFound do
      status 404
      format_response({error: 'The page you requested could not be found.'}, 'errors')
    end
  end
end

require 'sinatra/base'
require 'sinatra/router'
require 'dalli'
require 'rack-cache'
require './config/environment'
Dir.glob('./{models,controllers}/*.rb').each { |file| require file }
Dir.glob('./v*/{models,controllers}/*.rb').each { |file| require file }

class App < Sinatra::Base
  use Sinatra::Router do
    def valid_accept_header?(accept_header)
      valid_formats = ['json', 'xml', '*/*']
      header_valid = false

      valid_formats.each do |format|
        header_valid = true if accept_header =~ /application\/vnd.api_workshop.v\d\+#{format}/
      end

      header_valid
    end

    def api_version(accept_header)
      accept_header.split('.').last.split('+').first.capitalize
    end

    def version(version, &block)
      condition = lambda { |e| valid_accept_header?(e['HTTP_ACCEPT']) && version == api_version(e['HTTP_ACCEPT']) }

      block ? with_conditions(condition, &block) : condition
    end

    version 'V2' do
      mount V2::StoriesController
      mount V2::UsersController
    end

    version 'V1' do
      mount V1::StoriesController
      mount V1::UsersController
    end
  end
end

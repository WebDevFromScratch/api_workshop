require 'sinatra/base'
require 'active_record'
require 'json'

class ApplicationController < Sinatra::Base
  set :show_exceptions, false

  error ActiveRecord::RecordNotFound do
    status 404
    {error: 'The page you requested could not be found.'}.to_json
  end

  before do
    content_type 'application/json'
  end
end

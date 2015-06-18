require 'sinatra/base'
require 'json'
require 'dotenv'
require 'active_record'
require './models/story'
require 'pry'

ENV['RACK_ENV'] == 'test' ? Dotenv.load(File.expand_path('.env.test')) : Dotenv.load
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

class App < Sinatra::Base
  error ActiveRecord::RecordNotFound do
    status 404
    {error: 'The page you requested could not be found.'}.to_json
  end

  before do
    content_type 'application/json'
  end

  get '/api/stories' do
    {stories: Story.all}.to_json
  end

  get '/api/stories/:id' do
    story = Story.find(params[:id])
    story.to_json
  end
end

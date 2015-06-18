require 'sinatra/base'
require 'json'
require 'dotenv'
require 'active_record'
require './models/story'

ENV['RACK_ENV'] == 'test' ? Dotenv.load(File.expand_path('.env.test')) : Dotenv.load
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

class App < Sinatra::Base
  get '/api/stories' do
    {stories: Story.all}.to_json
  end

  get '/api/stories/:id' do
    begin
      story = Story.find(params[:id])
      story.to_json
    rescue ActiveRecord::RecordNotFound
      status 404
      {error: 'The page you requested could not be found.'}.to_json
    end
  end
end

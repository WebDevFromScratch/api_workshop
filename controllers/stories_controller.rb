require 'sinatra/base'
require './models/story'

class StoriesController < ApplicationController
  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, {error: 'Not authorized'}.to_json
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      if @auth.provided? && @auth.basic? && @auth.credentials
        username,password = @auth.credentials

        user = User.find_by(username: username)
        user && user.authenticate(password)
      end
    end
  end

  get '/' do
    {stories: Story.all}.to_json
  end

  get '/:id' do
    story = Story.find(params[:id])
    story.to_json
  end

  post '/' do
    protected!
    story_hash = JSON.parse(request.body.read)
    story = Story.new(story_hash)

    if story.save
      status 201
      headers 'Location' => "/api/stories/#{story.id}"
      {url: story.url, title: story.title}.to_json
    else
      errors = story.errors.messages

      (errors[:url] && errors[:url].include?('has already been taken')) ? status(409) : status(422)
      errors.to_json
    end
  end
end

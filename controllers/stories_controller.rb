require 'sinatra/base'
require './models/story'

class StoriesController < ApplicationController
  get '/' do
    {stories: Story.all}.to_json
  end

  get '/:id' do
    story = Story.find(params[:id])
    story.to_json
  end

  post '/' do
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

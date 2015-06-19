require 'sinatra/base'
require_relative '../models/story'

class StoriesController < ApplicationController
  get '/' do
    {stories: Story.all}.to_json
  end

  get '/:id' do
    story = Story.find(params[:id])
    story.to_json
  end
end

require 'sinatra/base'

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
        set_user_id_param(user.id) if user

        user && user.authenticate(password)
      end
    end

    def set_user_id_param(id)
      params[:user_id] = id
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

  put '/:id/vote' do
    protected!
    vote_hash = JSON.parse(request.body.read)
    user = User.find(params[:user_id])
    story = Story.find(params[:id])

    if user.voted_on_story?(story.id)
      vote = user.votes.find_by(story_id: params[:id])
      vote.current_value = vote.value
    else
      vote = Vote.new()
    end

    vote.update(new_value: vote_hash['value'], value: vote_hash['value'], user_id: user.id, story_id: story.id)

    if vote.save
      status 200
      {value: vote.value, user_id: vote.user_id, story_id: vote.story_id}.to_json
    else
      errors = vote.errors.messages

      status 409
      errors.to_json
    end
  end
end

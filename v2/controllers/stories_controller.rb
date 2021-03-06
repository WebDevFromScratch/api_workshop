require 'sinatra/base'

module V2
  class StoriesController < ApplicationController
    namespace '/stories' do
      helpers do
        def set_user_id_param(id)
          params[:user_id] = id
        end

        def set_story
          Story.find(params[:id])
        end

        def set_user
          User.find(params[:user_id])
        end

        def set_board
          Board.first # then there always has to be at least one board
        end
      end

      get '/' do
        board = set_board
        stories = Story.sorted_by_votes.page(params[:page]).per(10)

        last_modified(board.updated_at)
        set_pagination_header(stories)
        format_response(stories, 'stories')
      end

      get '/recent' do
        cache_control :public, max_age: 30
        format_response(Story.sorted_by_recent.limit(10), 'stories')
      end

      post '/' do
        protected!

        story_hash = parse_request_body(request.body.read)
        story = Story.new(story_hash)
        user = set_user
        story.user = user

        if story.save
          status 201
          headers 'Location' => "/api/stories/#{story.id}"
          format_response({url: story.url, title: story.title}, 'story')
        else
          errors = story.errors.messages

          (errors[:url] && errors[:url].include?(I18n.t('errors.taken'))) ? status(409) : status(422)
          format_response(errors, 'errors')
        end
      end

      get '/:id' do
        story = set_story
        format_response(story, 'story')
      end

      patch '/:id' do
        protected!

        story_hash = parse_request_body(request.body.read)
        story = set_story
        user = set_user
        story.title = story_hash['title']

        if user == story.user && story.save
          status 204
        elsif user != story.user
          respond_with_unauthorized
        else
          errors = story.errors.messages

          status 422
          format_response(errors, 'errors')
        end
      end

      delete '/:id' do
        protected!

        story = set_story
        user = set_user

        if user == story.user && story.delete
          status 204
        else
          respond_with_unauthorized
        end
      end

      put '/:id/vote' do
        protected!

        vote_hash = parse_request_body(request.body.read)
        story = set_story
        user = set_user

        if user.voted_on_story?(story.id)
          vote = user.votes.find_by(story_id: params[:id])
          vote.current_value = vote.value
        else
          vote = Vote.new()
        end

        vote.update(new_value: vote_hash['value'], value: vote_hash['value'], user_id: user.id, story_id: story.id)

        story.votes_count += 1 if vote.valid? && !user.voted_on_story?(story.id)

        if vote.save
          story.reload
          status 200
          format_response({value: vote.value, user_id: vote.user_id, story_id: vote.story_id}, 'vote')
        else
          errors = vote.errors.messages

          status 409
          format_response(errors, 'errors')
        end
      end

      delete '/:id/vote' do
        protected!

        story = set_story
        user = set_user

        if user.voted_on_story?(story.id)
          vote = user.votes.find_by(story_id: params[:id])

          vote.delete
          story.reload
          status 204
        else
          status 422
          format_response({error: I18n.t(:error_not_voted)}, 'errors')
        end
      end

      get '/:id/url' do
        story = set_story

        redirect to(story.url), 303
      end
    end
  end
end

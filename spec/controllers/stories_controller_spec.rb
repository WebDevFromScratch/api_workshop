require 'spec_helper'
require 'rack/test'
require 'json'

describe StoriesController do
  include Rack::Test::Methods

  let(:controller) { StoriesController.new }
  let(:app) { Rack::Lint.new(controller) }

  describe 'api' do
    before do
      @story1 = Story.create(id: 1, title: 'Story 1', url: 'http://story1.com')
      @story2 = Story.create(id: 2, title: 'Story 2', url: 'http://story2.net')
    end

    describe 'GET /' do
      it 'returns 200 status response and a list of stories' do
        get '/'

        expect(last_response.status).to eq(200)
        expect(json['stories'].length).to eq(2)
      end
    end

    describe 'GET /:id' do
      context 'a story exists' do
        it 'returns 200 status response and a story details' do
          get "/#{@story1.id}"

          expect(last_response.status).to eq(200)
          expect(json['url']).to eq(@story1.url)
          expect(json['title']).to eq(@story1.title)
        end
      end

      context 'a story doesn\'t exist' do
        it 'returns a 404 status response and an expected error' do
          get '/12223'

          expect(last_response.status).to eq(404)
          expect(json['error']).to eq('The page you requested could not be found.')
        end
      end
    end

    describe 'POST /' do
      context 'with valid data' do
        xit 'returns 201 status response and a story details' do
          post '/', {url: 'story url', title: 'story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

          expect(last_response.status).to eq(201)
          # expect(last_response.header['Location']).to eq('')
          expect(json['url']).to eq('story url')
          expect(json['title']).to eq('story title')
        end
      end

      context 'with invalid data' do
        xit 'returns 422 status and an expected error' do
          post '/', {url: '', title: ''}.to_json, 'CONTENT_TYPE' => 'application/json'

          expect(last_response.status).to eq(422)
          expect(json['error']).to eq('URL and/or title is missing.')
        end
      end

      context 'when a story url already exists in the database' do
        xit 'returns 409 status and an expected error' do
          post '/', {url: 'http://story1.com', title: 'story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

          expect(last_response.status).to eq(409)
          expect(json['error']).to eq('A story with this URL already exists.')
        end
      end
    end

    describe 'PATCH /:id' do
      context 'with valid data' do
        xit 'returns 204 status' do
          patch "/#{@story1.id}", {title: 'new story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

          expect(last_response.status).to eq(204)
        end
      end

      context 'with invalid data' do
        xit 'returns 422 status and an expected error' do
          patch "/#{@story1.id}", {title: ''}.to_json, 'CONTENT_TYPE' => 'application/json'

          expect(last_response.status).to eq(422)
          expect(json['error']).to eq('A title is missing.')
        end
      end
    end

    describe 'PUT /:id/vote' do
      context 'when a user votes up' do
        context 'when a user has not voted yet' do
          xit 'returns 200 status' do
            put "/#{@story1.id}/vote/", {vote: 'up'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(200)
            expect(json['vote']).to eq('up')
          end
        end

        context 'when a user has already voted down' do
          before { put "/#{@story1.id}/vote/", {vote: 'down'}.to_json, 'CONTENT_TYPE' => 'application/json' }

          xit 'returns 200 status' do
            put "/#{@story1.id}/vote/", {vote: 'up'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(200)
            expect(json['vote']).to eq('up')
          end
        end

        context 'when a user has already voted up' do
          before { put "/#{@story1.id}/vote/", {vote: 'up'}.to_json, 'CONTENT_TYPE' => 'application/json' }

          xit 'returns 409 status and an expected error' do
            put "/#{@story1.id}/vote/", {vote: 'up'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(409)
            expect(json['error']).to eq('You have already upvoted this story.')
          end
        end
      end

      context 'when a user votes down' do
        context 'when a user has not voted yet' do
          xit 'returns 200 status' do
            put "/#{@story1.id}/vote/", {vote: 'down'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(200)
            expect(json['vote']).to eq('down')
          end
        end

        context 'when a user has already voted up' do
          before { put "/#{@story1.id}/vote/", {vote: 'up'}.to_json, 'CONTENT_TYPE' => 'application/json' }

          xit 'returns 200 status' do
            put "/#{@story1.id}/vote/", {vote: 'down'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(200)
            expect(json['vote']).to eq('down')
          end
        end

        context 'when a user has already voted down' do
          before { put "/#{@story1.id}/vote/", {vote: 'down'}.to_json, 'CONTENT_TYPE' => 'application/json' }

          xit 'returns 409 status and an expected error' do
            put "/#{@story1.id}/vote/", {vote: 'down'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(409)
            expect(json['error']).to eq('You have already downvoted this story.')
          end
        end
      end
    end

    describe 'DELETE /:id/vote' do
      context 'when a user already casted a vote' do
        before { post "/#{@story1.id}/vote/up" }

        xit 'returns 204 status' do
          delete "/#{@story1.id}/vote"

          expect(last_response.status).to eq(204)
        end
      end

      context 'when a user did not cast a vote yet' do
        xit 'returns 422 status and an expected error' do
          delete "/#{@story1.id}/vote"

          expect(last_response.status).to eq(422)
          expect(json['error']).to eq('You have not voted yet.')
        end
      end
    end
  end
end

require 'spec_helper'
require 'rack/test'
require 'json'

# this file will eventually be removed

describe App do
  include Rack::Test::Methods

  let(:api_app) { App.new }
  let(:app) { Rack::Lint.new(api_app) }

  describe 'api' do
    before do
      @story1 = Story.create(id: 1, title: 'Story 1', url: 'http://story1.com')
      @story2 = Story.create(id: 2, title: 'Story 2', url: 'http://story2.net')
    end

    describe '/stories' do
      describe 'GET /' do
        xit 'returns 200 status response and a list of stories' do
          get '/api/stories'

          expect(last_response.status).to eq(200)
          expect(json['stories'].length).to eq(2)
        end
      end

      describe 'GET /:id' do
        context 'a story exists' do
          xit 'returns 200 status response and a story details' do
            get "/api/stories/#{@story1.id}"

            expect(last_response.status).to eq(200)
            expect(json['url']).to eq(@story1.url)
            expect(json['title']).to eq(@story1.title)
          end
        end

        context 'a story doesn\'t exist' do
          xit 'returns a 404 status response and an expected error' do
            get '/api/stories/12223'

            expect(last_response.status).to eq(404)
            expect(json['error']).to eq('The page you requested could not be found.')
          end
        end
      end

      describe 'POST /' do
        context 'with valid data' do
          xit 'returns 201 status response and a story details' do
            post '/api/stories', {url: 'story url', title: 'story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(201)
            # expect(last_response.header['Location']).to eq('')
            expect(json['url']).to eq('story url')
            expect(json['title']).to eq('story title')
          end
        end

        context 'with invalid data' do
          xit 'returns 422 status and an expected error' do
            post '/api/stories', {url: '', title: ''}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(422)
            expect(json['error']).to eq('URL and/or title is missing.')
          end
        end

        context 'when a story url already exists in the database' do
          xit 'returns 409 status and an expected error' do
            post '/api/stories', {url: 'http://story1.com', title: 'story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(409)
            expect(json['error']).to eq('A story with this URL already exists.')
          end
        end
      end

      describe 'PATCH /:id' do
        context 'with valid data' do
          xit 'returns 204 status' do
            patch "/api/stories/#{@story1.id}", {title: 'new story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(204)
          end
        end

        context 'with invalid data' do
          xit 'returns 422 status and an expected error' do
            patch "/api/stories/#{@story1.id}", {title: ''}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(422)
            expect(json['error']).to eq('A title is missing.')
          end
        end
      end

      describe 'PUT /:id/vote' do
        context 'when a user votes up' do
          context 'when a user has not voted yet' do
            xit 'returns 200 status' do
              put "/api/stories/#{@story1.id}/vote/", {vote: 'up'}.to_json, 'CONTENT_TYPE' => 'application/json'

              expect(last_response.status).to eq(200)
              expect(json['vote']).to eq('up')
            end
          end

          context 'when a user has already voted down' do
            before { put "/api/stories/#{@story1.id}/vote/", {vote: 'down'}.to_json, 'CONTENT_TYPE' => 'application/json' }

            xit 'returns 200 status' do
              put "/api/stories/#{@story1.id}/vote/", {vote: 'up'}.to_json, 'CONTENT_TYPE' => 'application/json'

              expect(last_response.status).to eq(200)
              expect(json['vote']).to eq('up')
            end
          end

          context 'when a user has already voted up' do
            before { put "/api/stories/#{@story1.id}/vote/", {vote: 'up'}.to_json, 'CONTENT_TYPE' => 'application/json' }

            xit 'returns 409 status and an expected error' do
              put "/api/stories/#{@story1.id}/vote/", {vote: 'up'}.to_json, 'CONTENT_TYPE' => 'application/json'

              expect(last_response.status).to eq(409)
              expect(json['error']).to eq('You have already upvoted this story.')
            end
          end
        end

        context 'when a user votes down' do
          context 'when a user has not voted yet' do
            xit 'returns 200 status' do
              put "/api/stories/#{@story1.id}/vote/", {vote: 'down'}.to_json, 'CONTENT_TYPE' => 'application/json'

              expect(last_response.status).to eq(200)
              expect(json['vote']).to eq('down')
            end
          end

          context 'when a user has already voted up' do
            before { put "/api/stories/#{@story1.id}/vote/", {vote: 'up'}.to_json, 'CONTENT_TYPE' => 'application/json' }

            xit 'returns 200 status' do
              put "/api/stories/#{@story1.id}/vote/", {vote: 'down'}.to_json, 'CONTENT_TYPE' => 'application/json'

              expect(last_response.status).to eq(200)
              expect(json['vote']).to eq('down')
            end
          end

          context 'when a user has already voted down' do
            before { put "/api/stories/#{@story1.id}/vote/", {vote: 'down'}.to_json, 'CONTENT_TYPE' => 'application/json' }

            xit 'returns 409 status and an expected error' do
              put "/api/stories/#{@story1.id}/vote/", {vote: 'down'}.to_json, 'CONTENT_TYPE' => 'application/json'

              expect(last_response.status).to eq(409)
              expect(json['error']).to eq('You have already downvoted this story.')
            end
          end
        end
      end

      describe 'DELETE /:id/vote' do
        context 'when a user already casted a vote' do
          before { post "/api/stories/#{@story1.id}/vote/up" }

          xit 'returns 204 status' do
            delete "/api/stories/#{@story1.id}/vote"

            expect(last_response.status).to eq(204)
          end
        end

        context 'when a user did not cast a vote yet' do
          xit 'returns 422 status and an expected error' do
            delete "/api/stories/#{@story1.id}/vote"

            expect(last_response.status).to eq(422)
            expect(json['error']).to eq('You have not voted yet.')
          end
        end
      end
    end

    describe '/users' do
      describe 'POST /' do
        context 'with valid data' do
          xit 'returns 201 status' do
            post '/api/users', {username: 'JohnDoe', password: 'secret123'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(201)
            # expect(last_response.header['Location']).to eq('')
            expect(json['username']).to eq('JohnDoe')
            expect(json['password']).to eq('secret123')
          end
        end

        context 'with invalid data' do
          xit 'returns 422 status and an expected error' do
            post '/api/users', {username: '', password: ''}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(422)
            expect(json['error']).to eq('Username and/or password is missing.')
          end
        end

        context 'when a username is already taken' do
          before { User.create(username: 'JohnDoe', password: 'secret123') }

          xit 'returns 409 status and an expected error' do
            post '/api/users', {username: 'JohnDoe', password: 'secret567'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(409)
            expect(json['error']).to eq('Username is already taken.')
          end
        end
      end
    end
  end
end

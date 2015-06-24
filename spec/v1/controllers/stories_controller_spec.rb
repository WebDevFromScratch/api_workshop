require 'spec_helper'
require 'rack/test'

describe V1::StoriesController do
  include Rack::Test::Methods

  let(:controller) { V1::StoriesController.new }
  let(:app) { Rack::Lint.new(controller) }

  before do
    @user = User.create(username: 'John', password: 'secret123')
    @another_user = User.create(username: 'Bob', password: 'password')
    @story1 = Story.create(title: 'Story 1', url: 'http://story1.com/', user_id: @user.id)
    @story2 = Story.create(title: 'Story 2', url: 'http://story2.net/', user_id: @user.id)
  end

  describe 'GET / with XML format' do
    it 'returns 200 status response and a list of stories' do
      header 'Accept', 'application/xml'
      get '/'

      expect(last_response.status).to eq(200)
      expect(xml['stories'].length).to eq(2)
    end
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
        expect(json['story']['url']).to eq(@story1.url)
        expect(json['story']['title']).to eq(@story1.title)
        expect(json['story']['score']).to eq(0)
      end

      context 'and story score' do
        before do
          authorize 'John', 'secret123'
        end

        context 'after adding a vote' do
          before { put "/#{@story1.id}/vote", {value: 1}.to_json, 'CONTENT_TYPE' => 'application/json' }

          it 'updates correctly' do
            get "/#{@story1.id}"

            expect(json['story']['score']).to eq(1)
          end
        end

        context 'after changing a vote' do
          before do
            put "/#{@story1.id}/vote", {value: 1}.to_json, 'CONTENT_TYPE' => 'application/json'
            put "/#{@story1.id}/vote", {value: -1}.to_json, 'CONTENT_TYPE' => 'application/json'
          end

          it 'updates correctly' do
            get "/#{@story1.id}"

            expect(json['story']['score']).to eq(-1)
          end
        end

        context 'after removing a vote' do
          before do
            put "/#{@story1.id}/vote", {value: 1}.to_json, 'CONTENT_TYPE' => 'application/json'
            delete "/#{@story1.id}/vote"
          end

          it 'updates correctly' do
            get "/#{@story1.id}"

            expect(json['story']['score']).to eq(0)
          end
        end
      end
    end

    context 'a story doesn\'t exist' do
      it 'returns a 404 status response and an expected error' do
        get '/12223'

        expect(last_response.status).to eq(404)
        expect(json['errors']['error']).to eq('The page you requested could not be found.')
      end
    end
  end

  describe 'POST /' do
    context 'with an authorized user' do
      before { authorize 'John', 'secret123' }

      context 'with valid data' do
        it 'returns 201 status response and a story details' do
          post '/', {url: 'story url', title: 'story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

          expect(last_response.status).to eq(201)
          expect(last_response.header['Location']).to eq("/api/stories/#{Story.last.id}")
          expect(json['story']['url']).to eq('story url')
          expect(json['story']['title']).to eq('story title')
        end
      end

      context 'with invalid data' do
        it 'returns 422 status and an expected error' do
          post '/', {url: '', title: ''}.to_json, 'CONTENT_TYPE' => 'application/json'

          expect(last_response.status).to eq(422)
          expect(json['errors']['url']).to include('can\'t be blank')
          expect(json['errors']['title']).to include('can\'t be blank')
        end
      end

      context 'when a story url already exists in the database' do
        it 'returns 409 status and an expected error' do
          post '/', {url: "#{@story1.url}", title: 'story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

          expect(last_response.status).to eq(409)
          expect(json['errors']['url']).to include('has already been taken')
        end
      end
    end

    context 'without an authorized user' do
      before { authorize 'Menace', 'password' }

      it 'returns 401 status response and an expected error' do
        post '/', {url: 'story url', title: 'story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response.status).to eq(401)
        expect(last_response.header['WWW-Authenticate']).to eq('Basic realm="Restricted Area"')
        expect(json['errors']['error']).to eq('Not authorized')
      end
    end
  end

  describe 'PATCH /:id' do
    context 'with an authorized user' do
      context 'who is an autor of the story' do
        before { authorize 'John', 'secret123' }

        context 'with valid data' do
          it 'returns 204 status' do
            patch "/#{@story1.id}", {title: 'new story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(204)
          end
        end

        context 'with invalid data' do
          it 'returns 422 status and an expected error' do
            patch "/#{@story1.id}", {title: ''}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(422)
            expect(json['errors']['title']).to include('can\'t be blank')
          end
        end
      end

      context 'who is not an author of the story' do
        before { authorize 'Bob', 'password' }

        it 'returns 401 status response and an expected error' do
          patch "/#{@story1.id}", {title: 'new story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

          expect(last_response.status).to eq(401)
          expect(last_response.header['WWW-Authenticate']).to eq('Basic realm="Restricted Area"')
          expect(json['errors']['error']).to eq('Not authorized')
        end
      end
    end

    context 'without an authorized user' do
      it 'returns 401 status response and an expected error' do
        patch "/#{@story1.id}", {title: 'new story title'}.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response.status).to eq(401)
        expect(last_response.header['WWW-Authenticate']).to eq('Basic realm="Restricted Area"')
        expect(json['errors']['error']).to eq('Not authorized')
      end
    end
  end

  describe 'PUT /:id/vote' do
    context 'with an authorized user' do
      before { authorize 'John', 'secret123' }

      context 'when a user votes up' do
        context 'when a user has not voted yet' do
          it 'returns 200 status and an expected response' do
            put "/#{@story1.id}/vote", {value: 1}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(200)
            expect(json['vote']['value']).to eq(1)
            expect(json['vote']['user_id']).to eq(@user.id)
            expect(json['vote']['story_id']).to eq(@story1.id)
          end
        end

        context 'when a user has already voted down' do
          before { put "/#{@story1.id}/vote", {value: -1}.to_json, 'CONTENT_TYPE' => 'application/json' }

          it 'returns 200 status and an expected response' do
            put "/#{@story1.id}/vote", {value: 1}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(200)
            expect(json['vote']['value']).to eq(1)
            expect(json['vote']['user_id']).to eq(@user.id)
            expect(json['vote']['story_id']).to eq(@story1.id)
          end
        end

        context 'when a user has already voted up' do
          before { put "/#{@story1.id}/vote", {value: 1}.to_json, 'CONTENT_TYPE' => 'application/json' }

          it 'returns 409 status and an expected error' do
            put "/#{@story1.id}/vote", {value: 1}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(409)
            expect(json['errors']['error']).to include('You have only one vote (up or down).')
          end
        end
      end

      context 'when a user votes down' do
        context 'when a user has not voted yet' do
          it 'returns 200 status' do
            put "/#{@story1.id}/vote", {value: -1}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(200)
            expect(json['vote']['value']).to eq(-1)
            expect(json['vote']['user_id']).to eq(@user.id)
            expect(json['vote']['story_id']).to eq(@story1.id)
          end
        end

        context 'when a user has already voted up' do
          before { put "/#{@story1.id}/vote", {value: 1}.to_json, 'CONTENT_TYPE' => 'application/json' }

          it 'returns 200 status' do
            put "/#{@story1.id}/vote", {value: -1}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(200)
            expect(json['vote']['value']).to eq(-1)
            expect(json['vote']['user_id']).to eq(@user.id)
            expect(json['vote']['story_id']).to eq(@story1.id)
          end
        end

        context 'when a user has already voted down' do
          before { put "/#{@story1.id}/vote", {value: -1}.to_json, 'CONTENT_TYPE' => 'application/json' }

          it 'returns 409 status and an expected error' do
            put "/#{@story1.id}/vote", {value: -1}.to_json, 'CONTENT_TYPE' => 'application/json'

            expect(last_response.status).to eq(409)
            expect(json['errors']['error']).to include('You have only one vote (up or down).')
          end
        end
      end
    end

    context 'without an authorized user' do
      it 'returns 401 status and an expected error' do
        put "/#{@story1.id}/vote", {value: 1}.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response.status).to eq(401)
        expect(last_response.header['WWW-Authenticate']).to eq('Basic realm="Restricted Area"')
        expect(json['errors']['error']).to eq('Not authorized')
      end
    end
  end

  describe 'DELETE /:id/vote' do
    context 'with an authorized user' do
      before { authorize 'John', 'secret123' }

      context 'when a user already casted a vote' do
        before { put "/#{@story1.id}/vote", {value: 1}.to_json, 'CONTENT_TYPE' => 'application/json' }

        it 'returns 204 status' do
          delete "/#{@story1.id}/vote"

          expect(last_response.status).to eq(204)
        end
      end

      context 'when a user did not cast a vote yet' do
        it 'returns 422 status and an expected error' do
          delete "/#{@story1.id}/vote"

          expect(last_response.status).to eq(422)
          expect(json['errors']['error']).to eq('You have not voted yet.')
        end
      end
    end
  end

  describe 'GET /:id/url' do
    it 'returns 303 status and redirect to an expected url' do
      get "/#{@story1.id}/url"

      expect(last_response.status).to eq(303)
      follow_redirect!
      expect(last_request.url).to eq(@story1.url)
    end
  end
end

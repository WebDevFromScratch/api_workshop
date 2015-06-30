require 'spec_helper'
require 'rack/test'
require 'json'

describe V2::UsersController do
  include Rack::Test::Methods

  let(:controller) { V2::UsersController.new }
  let(:app) { Rack::Lint.new(controller) }

  describe 'POST /' do
    before { header 'Accept', 'application/vnd.api_workshop.v2+json' }

    context 'with valid data' do
      it 'returns 201 status' do
        post '/users/', {username: 'JohnDoe', password: 'secret123'}.to_json

        expect(last_response.status).to eq(201)
        expect(last_response.header['Location']).to eq("/api/users/#{User.last.id}")
        expect(json['user']['username']).to eq('JohnDoe')
      end
    end

    context 'with invalid data' do
      it 'returns 422 status and an expected error' do
        post '/users/', {username: '', password: 'short'}.to_json

        expect(last_response.status).to eq(422)
        expect(json['errors']['username']).to include('can\'t be blank')
        expect(json['errors']['password']).to include('is too short (minimum is 6 characters)')
      end
    end

    context 'when a username is already taken' do
      before { User.create(username: 'JohnDoe', password: 'secret123') }

      it 'returns 409 status and an expected error' do
        post '/users/', {username: 'JohnDoe', password: 'secret567'}.to_json

        expect(last_response.status).to eq(409)
        expect(json['errors']['username']).to include('has already been taken')
      end
    end
  end
end

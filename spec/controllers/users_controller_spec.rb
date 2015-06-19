require 'spec_helper'
require 'rack/test'
require 'json'

describe UsersController do
  include Rack::Test::Methods

  let(:controller) { UsersController.new }
  let(:app) { Rack::Lint.new(controller) }

  describe 'POST /' do
    context 'with valid data' do
      it 'returns 201 status' do
        post '/', {username: 'JohnDoe', password: 'secret123'}.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response.status).to eq(201)
        expect(last_response.header['Location']).to eq("/api/users/#{User.last.id}")
        expect(json['username']).to eq('JohnDoe')
      end
    end

    context 'with invalid data' do
      it 'returns 422 status and an expected error' do
        post '/', {username: '', password: 'short'}.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response.status).to eq(422)
        expect(json['username']).to include('can\'t be blank')
        expect(json['password']).to include('is too short (minimum is 6 characters)')
      end
    end

    context 'when a username is already taken' do
      before { User.create(username: 'JohnDoe', password: 'secret123') }

      it 'returns 409 status and an expected error' do
        post '/', {username: 'JohnDoe', password: 'secret567'}.to_json, 'CONTENT_TYPE' => 'application/json'

        expect(last_response.status).to eq(409)
        expect(json['username']).to include('has already been taken')
      end
    end
  end
end
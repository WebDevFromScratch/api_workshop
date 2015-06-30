require 'sinatra/base'
require './models/user'

module V2
  class UsersController < ApplicationController
    namespace '/users' do
      post '/' do
        user_hash = parse_request_body(request.body.read)
        user = User.new(user_hash)

        if user.save
          status 201
          headers 'Location' => "/api/users/#{user.id}"
          format_response({username: user.username}, 'user')
        else
          errors = user.errors.messages

          (errors[:username] && errors[:username].include?('has already been taken')) ? status(409) : status(422)
          format_response(errors, 'errors')
        end
      end
    end
  end
end

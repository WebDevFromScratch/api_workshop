require 'sinatra/base'
require './models/user'

class UsersController < ApplicationController
  post '/' do
    user_hash = parse_request_body(request.body.read)
    # user_hash = JSON.parse(request.body.read)
    user = User.new(user_hash)

    if user.save
      status 201
      headers 'Location' => "/api/users/#{user.id}"
      format_response({username: user.username}, 'user')
      # {username: user.username}.to_json
    else
      errors = user.errors.messages

      (errors[:username] && errors[:username].include?('has already been taken')) ? status(409) : status(422)
      # errors.to_json
      format_response(errors, 'errors')
    end
  end
end

require 'sinatra/base'
require './models/user'

require 'pry'

class UsersController < ApplicationController
  post '/' do
    user_hash = JSON.parse(request.body.read)
    user = User.new(user_hash)

    if user.save
      status 201
      headers 'Location' => "/api/users/#{user.id}"
      {username: user.username}.to_json
    else
      errors = user.errors.messages

      (errors[:username] && errors[:username].include?('has already been taken')) ? status(409) : status(422)
      errors.to_json
    end
  end
end

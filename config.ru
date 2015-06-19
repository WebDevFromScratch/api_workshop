require 'sinatra/base'
require 'dotenv'

require './app'

map('/') { run App }
map('/api/') { run ApplicationController }
map('/api/stories') { run StoriesController }
map('/api/users') { run UsersController }

require 'sinatra/base'
require 'dotenv'

require './app'
Dir.glob('./{helpers,controllers}/*.rb').each { |file| require file }

map('/') { run App }
map('/api/') { run ApplicationController }
map('/api/stories') { run StoriesController }
map('/api/users') { run UsersController }

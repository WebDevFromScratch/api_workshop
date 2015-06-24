require 'sinatra/base'
require 'dotenv'

require './app'

map('/') { run App }

map('/api/v1') { run V1::ApplicationController }
map('/api/v1/stories') { run V1::StoriesController }
map('/api/v1/users') { run V1::UsersController }

map('/api/v2') { run V2::ApplicationController }
map('/api/v2/stories') { run V2::StoriesController }
map('/api/v2/users') { run V2::UsersController }

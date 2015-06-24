require 'sinatra/base'
require './config/environment'
Dir.glob('./{models,controllers}/*.rb').each { |file| require file }

Dir.glob('./v*/{models,controllers}/*.rb').each { |file| require file }

class App < Sinatra::Base
end

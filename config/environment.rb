require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'active_record'
require 'dotenv'

ENV['RACK_ENV'] == 'test' ? Dotenv.load(File.expand_path('.env.test')) : Dotenv.load
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

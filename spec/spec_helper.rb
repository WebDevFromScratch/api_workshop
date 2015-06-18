ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../..', __FILE__)
require 'app'
require 'support/request_helpers'
require 'models/story'
require 'database_cleaner'

RSpec.configure do |config|
  config.include RequestHelpers

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

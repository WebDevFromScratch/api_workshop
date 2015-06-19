ENV['RACK_ENV'] = 'test'

require 'database_cleaner'
require 'support/request_helpers'
require_relative '../app'
require_relative '../controllers/application_controller'
require_relative '../controllers/stories_controller'

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

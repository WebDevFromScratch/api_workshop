ENV['RACK_ENV'] = 'test'

require 'database_cleaner'
require 'support/request_helpers'
require './app'
Dir["./v*/controllers/*.rb"].each {|file| require file }

RSpec.configure do |config|
  config.include RequestHelpers
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

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

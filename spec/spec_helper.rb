$LOAD_PATH.unshift File.expand_path('../..', __FILE__)
require 'app'
require 'support/request_helpers'

RSpec.configure do |config|
  config.include RequestHelpers
end

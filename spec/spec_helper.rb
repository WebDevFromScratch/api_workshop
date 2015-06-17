$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'api_workshop'
require 'support/request_helpers'

RSpec.configure do |config|
  config.include RequestHelpers
end

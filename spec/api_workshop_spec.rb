require 'spec_helper'
require 'rack/test'

describe ApiWorkshop do
  include Rack::Test::Methods

  let(:api_app) { ApiWorkshop.new }
  let(:app) { Rack::Lint.new(api_app) }
  before { get '/' }

  it 'response should be okay' do
    expect(last_response).to be_ok
  end
end

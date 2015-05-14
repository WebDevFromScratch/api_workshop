require 'spec_helper'
require 'rack/test'

describe ApiWorkshop do
  include Rack::Test::Methods

  let(:app) { ApiWorkshop.new }
  before { get '/' }

  it 'response should be okay' do
    expect(last_response).to be_ok
  end
end

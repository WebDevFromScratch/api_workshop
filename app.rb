require 'sinatra/base'
require 'json'

class App < Sinatra::Base
  get '/api/stories' do
    content_type :json
    {
      stories: [
        {
          id: 1,
          url: 'http://story1.com',
          title: 'Story 1'
        },
        {
          id: 2,
          url: 'http://story2.net',
          title: 'Story 2'
        }
      ]
    }.to_json
  end

  get '/api/stories/1' do
    content_type :json
    {
      id: 1,
      url: 'http://story1.com',
      title: 'Story 1'
    }.to_json
  end
end

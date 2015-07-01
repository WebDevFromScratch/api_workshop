require 'i18n'
require 'i18n/backend/fallbacks'
require 'rack'
require 'rack/contrib'

class App < Sinatra::Base
  configure do
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join('./', 'locales', '*.yml')]
    I18n.backend.load_translations
    I18n.enforce_available_locales = false
  end

  use Rack::Locale
end

require 'i18n'
require 'rack'

class App < Sinatra::Base
  configure do
    I18n.load_path = Dir[File.join('./', 'locales', '*.yml')]
    I18n.backend.load_translations
    I18n.available_locales = %w(pl en)
    I18n.default_locale = 'en'
  end
end

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Namasdatum::Application.initialize!

Gowalla.configure do |config|
  config.api_key = Settings.gowalla_app_api_key
  config.api_secret = Settings.gowalla_app_secret
end
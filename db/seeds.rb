require 'factory_girl'
require 'test/factories'

config = (
  config_path = File.read(File.dirname(__FILE__) + "/seeds.yml")
  YAML.load(config_path)["config"]
)

jason = Factory.create(:user,
  :username => 'jason',
  :email => 'jason.cale@me.com',
  :password => 'testing',
  :password_confirmation => 'testing',
  :mindbodyonline_user => config[:jason][:mindbodyonline_user],
  :mindbodyonline_pw => config[:jason][:mindbodyonline_password]
)

jason.fetch_lesson_history
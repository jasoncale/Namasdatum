require 'faker'
require 'factory_girl'

Factory.define(:user) do |f|
  f.username { Faker::Internet.user_name }
  f.email { Faker::Internet.email }
  f.password "password"
  f.password_confirmation "password"
end
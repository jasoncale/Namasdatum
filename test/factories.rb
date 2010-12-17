require 'faker'
require 'factory_girl'

Factory.define(:user) do |f|
  f.username { Faker::Internet.user_name }
  f.email { Faker::Internet.email }
  f.password "password"
  f.password_confirmation "password"
  f.mindbodyonline_user "user"
  f.mindbodyonline_pw "password"
end

Factory.define(:studio) do |f|
  f.name { "Balham" }
end

Factory.define(:teacher) do |f|
  f.name { "John Finn" }
end

Factory.define(:lesson) do |f|
  f.attended_at { Time.local(Time.now.year, Time.now.month, Time.now.day, 10) }
  f.association :studio
  f.association :user
  f.association :teacher
end
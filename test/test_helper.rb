ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/test_unit'
require 'factories'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  
  def teardown
    Timecop.return
  end

  # Add more helper methods to be used by all tests here...

  def sign_up(attributes)
    attributes.reverse_merge!(Factory.attributes_for(:user))

    visit '/users/sign_up'    
    fill_in 'Username', :with => attributes[:username]
    fill_in 'Email', :with => attributes[:email]
    fill_in 'Password', :with => attributes[:password]
    fill_in 'Password confirmation', :with => attributes[:password]
    click_button 'Sign up'
    
    return User.find_by_username(attributes[:username])
  end
  
  def sign_up_sign_out_sign_in(attributes)
    sign_up(attributes)
    sign_out
    sign_in(attributes)
  end
  
  def sign_in(attributes)
    attributes.reverse_merge!(Factory.attributes_for(:user))
    
    visit '/'
    click_link 'Sign in'    
    fill_in 'Username', :with => attributes[:username]
    fill_in 'Password', :with => attributes[:password]
    click_button 'Sign in'
    
    return User.find_by_username(attributes[:username])
  end
  
  def sign_out
    click_link 'Sign out'
  end
  
  # IMPORTING DATA
  
  def import_html(filename)
    return File.read(File.join(Rails.root, 'test/fixtures/html_content', "#{filename}.html"))
  end
  
  def html_body(filename)
    {
      :body => import_html(filename),
      :headers => { "Content-Type" => "text/html" }
    }
  end
  
  def stub_user_history(user_history_filename)
    # stub home page
    stub_request(:get, "https://clients.mindbodyonline.com/ASP/home.asp?studioid=1134").to_return(
      html_body('app_index')
    )
    
    # stub session creation post
    stub_request(:post, "https://clients.mindbodyonline.com/ASP/home.asp?studioid=1134")
    
    # stub logging in
    stub_request(:post, "https://clients.mindbodyonline.com/ASP/login_p.asp")
    
    # stub getting user history
    stub_request(:get, "https://clients.mindbodyonline.com/ASP/my_vh.asp?tabID=2").to_return(
      html_body(user_history_filename)
    )
  end
  
  def attend_class_time(user, date = Time.zone.now, hour = 10)
    class_time = Time.utc(date.year, date.month, date.day, hour)
    user.lessons.create(:attended_at => class_time)
  end

  def streak_for(user, length_in_days = 1.day)
    (length_in_days / 1.day).times do |x|
      attend_class_time(user, (x + 1).days.ago)
    end
  end

end

class ActionController::TestCase
  include Devise::TestHelpers
end

# Enable Capybara for integration tests
require 'capybara/rails'
ActionController::IntegrationTest.send(:include, Capybara)
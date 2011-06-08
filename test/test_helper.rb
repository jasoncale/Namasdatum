ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/test_unit'
require 'factories'
require 'mocha'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  
  def teardown
    Timecop.return
  end

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
  
  def attend_class_time(user, date = Time.zone.now, hour = 10, studio = default_studio)
    class_time = Time.utc(date.year, date.month, date.day, hour)
    Factory.create(:lesson, :attended_at => class_time, :user => user, :studio => studio)
  end

  def streak_for(user, length_in_days = 1.day)
    (length_in_days / 1.day).times do |x|
      attend_class_time(user, (x + 1).days.ago)
    end
  end
  
  def default_studio
    @default_studio ||= Studio.find_or_create_by_name("Balham")
  end
  
  # FOURSQUARE HELPERS

  def today_began_at
    Time.local(Date.today.year, Date.today.month, Date.today.day).utc.to_i
  end

  def stub_foursquare_checkins(checkins = [])
    @foursquare_checkins = mock()
    @foursquare_checkins.stubs(:all).with({:afterTimestamp => today_began_at}).returns(checkins)
    Foursquare::Base.any_instance.stubs(:checkins).returns(@foursquare_checkins)
    return @foursquare_checkins
  end
  
  def foursquare_checkins
    @foursquare_checkins ||= stub_foursquare_checkins([])
  end
  
  def stub_foursquare_checkin_for(venue)
    foursquare_checkins.expects(:create).once.with({
      :venueId => venue.foursquare_venue_id, 
      :broadcast => "public"
    }).returns(stub_everything("checkin", :venue => venue.name))
  end
  
  def stub_foursquare_user_checkin(user, venue)
    foursquare = Foursquare::Base.new(user.foursquare_access_token)
    checkin = Foursquare::Checkin.new(foursquare, {})
    venue = Foursquare::Venue.new(foursquare, {'id' => venue.foursquare_venue_id})    
    checkin.stubs(:venue => venue)
    return checkin
  end
  
end

class ActionController::TestCase
  include Devise::TestHelpers
end

# Enable Capybara for integration tests
require 'capybara/rails'
ActionController::IntegrationTest.send(:include, Capybara)
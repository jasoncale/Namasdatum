require 'test_helper'

class UserSignupFlowTest < ActionDispatch::IntegrationTest
  
  context "Signing up for an account" do
    setup do
      sign_up(:username => 'john')
    end
    
    should "show their profile page" do
      assert page.has_content?('john')
    end
    
    should "create new user" do
      assert_equal(1, User.count)
    end

  end
  
  context "Logging into an account" do
    setup do
      sign_up(:username => 'john')
      sign_out
      sign_in(:username => 'john')
    end

    should "show their profile page" do
      assert page.has_content?('john')
    end
  end
  
  private
  
  def sign_up(attributes)
    attributes.reverse_merge!(Factory.attributes_for(:user))

    visit '/users/sign_up'    
    fill_in 'Username', :with => attributes[:username]
    fill_in 'Email', :with => attributes[:email]
    fill_in 'Password', :with => attributes[:password]
    fill_in 'Password confirmation', :with => attributes[:password]
    click_button 'Sign up'
  end
  
  def sign_in(attributes)
    attributes.reverse_merge!(Factory.attributes_for(:user))

    visit '/users/sign_in'
    fill_in 'Username', :with => attributes[:username]
    fill_in 'Password', :with => attributes[:password]
    click_button 'Sign in'
  end
  
  def sign_out
    visit '/users/sign_out'
  end
  
end

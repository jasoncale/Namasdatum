require 'test_helper'

class UserSignupFlowTest < ActionDispatch::IntegrationTest
  
  context "Signing up for an account" do
    setup do
      signup_as('john')
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
      signup_as('john')
      signout
      signin_as('john')
    end

    should "show their profile page" do
      assert page.has_content?('john')
    end
  end
  
  private
  
  def signup_as(username)
    visit '/users/sign_up'
    fill_in 'Username', :with => username
    fill_in 'Email', :with => 'john@yogabitch.com'
    fill_in 'Password', :with => "testing"
    fill_in 'Password confirmation', :with => "testing"
    click_button 'Sign up'
  end
  
  def signin_as(username, password = 'testing')
    visit '/users/sign_in'
    fill_in 'Username', :with => username
    fill_in 'Password', :with => password
    click_button 'Sign in'
  end
  
  def signout
    visit '/users/sign_out'
  end
  
end

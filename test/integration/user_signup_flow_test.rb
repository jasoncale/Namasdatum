require 'test_helper'

class UserSignupFlowTest < ActionDispatch::IntegrationTest
  
  context "Signing up for an account" do
    setup do
      sign_up(:username => 'john')
    end
    
    should "show their profile page" do
      assert page.has_css?('.calendar')
    end
    
    should "create new user" do
      assert_equal(1, User.count)
    end

  end
  
  context "Logging into an account" do
    setup do
      sign_up_sign_out_sign_in(:username => 'john')
    end

    should "show their profile page" do
      assert page.has_css?('.calendar')
    end
  end
    
end

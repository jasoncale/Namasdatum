require 'test_helper'

class GeneralLayoutTest < ActionDispatch::IntegrationTest

  context "when logged out" do
    setup do
      visit '/'
    end

    should "see sign up form" do
      assert page.has_content?('Sign up')
      assert page.has_css?('form#user_new')
    end

    should "have link to sign in" do
      assert page.has_css?('a[href*=sign_in]', :with => "Sign in")
    end
  
    context "visiting sign in page" do
      setup do
        click_link "Sign in"
      end

      should "have link back to sign up" do
        assert page.has_css?('a[href*=sign_up]', :with => "Sign up")
      end
    end
  end
    
  context "when logged in" do
    setup do
      sign_up_sign_out_sign_in(:username => "frank")
    end
    
    context "Primary navigation" do  
      should "have link to sign out" do
        assert page.has_css?('a[href*=sign_out]', :with => "Sign out")
      end
    end
  end
      
end
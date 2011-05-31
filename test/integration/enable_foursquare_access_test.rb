require 'test_helper'

class EnableFoursquareAccessTest < ActionDispatch::IntegrationTest
  
  context "User with an account" do
    setup do
      @user = sign_up(:username => "Kevin")
      click_link 'Account'
    end
    
    context "with no foursquare token" do
      should "not have token associated" do
        assert_nil @user.foursquare_access_token
      end
      
      should "see connect to foursquare link" do
        assert page.has_css?('a#foursquare_connect', :count => 1)
      end
    end
    
    context "with foursquare token" do
      setup do
        @user.update_attribute(:foursquare_access_token, "EXAMPLE_TOKEN")
        click_link 'Account'
      end
      
      should "see link to revoke access" do
        assert page.has_css?('input#unlink_foursquare', :count => 1)
      end
      
      context "clicking on the remove user access" do
        setup do
          click_button 'Unlink your account'
          click_link 'Account'
        end
      
        should "now see connect to foursquare link" do
          assert page.has_css?('a#foursquare_connect', :count => 1)
        end
      end
      
    end
    
  end
end

require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers
  tests RegistrationsController

  context "Signed in" do
    setup do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = Factory.create(:user)
      sign_in @user
    end

    context "receiving callback from gowalla" do
      setup do        
        @oauth_token_expires_at = Time.now.utc + 2.weeks
        stub_request(:post, "https://gowalla.com/api/oauth/token").to_return(:status => 200, :body => {
          :access_token => "oauth-token",
          :refresh_token => "refresh-token",
          :expires_in => 2.weeks.to_i,
          :username => "gowalla-user"
        }.to_json, :headers => {})
        get :gowalla_callback, :state => 1, :code => "gowalla-originated-code"
        @user.reload
      end

      should "update the gowalla access token" do
        assert_equal "oauth-token", @user.gowalla_access_token
      end
      
      should "set the gowalla oauth refresh token" do
        assert_equal "refresh-token", @user.gowalla_refresh_token
      end
      
      should "set the gowalla token expires date" do
        assert_equal @oauth_token_expires_at.to_i, @user.gowalla_access_token_expires_at.to_i
      end
      
      should "set the gowalla username" do
        assert_equal("gowalla-user", @user.gowalla_username)
      end
    end
    
    context "receiving callback from foursquare" do
      setup do
        Foursquare::Base.any_instance.stubs(:access_token).returns("oauth-token")
        get :foursquare_callback, :code => "foursquare-originated-code"
        @user.reload
      end

      should "update the foursquare access token" do
        assert_equal "oauth-token", @user.foursquare_access_token
      end
    end
  
  end  
end

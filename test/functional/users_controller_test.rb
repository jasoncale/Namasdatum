require 'test_helper'

class UsersControllerTest < ActionController::TestCase  
  context "Visiting user profile" do
    setup do
      @user = Factory.create(:user, :username => "kevin")
      get :show, :id => "kevin"
    end

    should "be successful" do
      assert_response :success
    end
  end  
  
  context "Attempting to view user profile that doesn't exist" do
    should "raise ActiveRecord::RecordNotFound which will invoke 404 in production" do
      assert_raise(ActiveRecord::RecordNotFound) { get :show, :id => 'john' }
    end
  end
end

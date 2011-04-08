require 'test_helper'

class AchievementTest < ActiveSupport::TestCase

  context "A user" do
    setup do
      @user = Factory.create(:user)
    end
    
    context "who does 30 straight days of yoga" do
      setup do
        Factory.create(:achievement, :name => "30 Day Challenge")
        
        streak_for @user, 30.days
        @user.update_progress(@user.lessons)
      end

      should "get the 30 day challenge achievement" do
        assert @user.achievements.map(&:name).include?("30 Day Challenge")
      end
    end
  end
end

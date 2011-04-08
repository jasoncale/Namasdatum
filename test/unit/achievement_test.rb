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
    
    context "who does 60 straight days of yoga" do
      setup do
        Factory.create(:achievement, :name => "60 Day Challenge")
        
        streak_for @user, 60.days
        @user.update_progress(@user.lessons)
      end

      should "get the 30 day challenge achievement" do
        assert @user.achievements.map(&:name).include?("60 Day Challenge")
      end
    end
    
    context "who does 90 straight days of yoga" do
      setup do
        Factory.create(:achievement, :name => "90 Day Challenge")
        
        streak_for @user, 90.days
        @user.update_progress(@user.lessons)
      end

      should "get the 90 day challenge achievement" do
        assert @user.achievements.map(&:name).include?("90 Day Challenge")
      end
    end
    
    context "who does 101 straight days of yoga" do
      setup do
        Factory.create(:achievement, :name => "101 Day Challenge")
        
        streak_for @user, 101.days
        @user.update_progress(@user.lessons)
      end

      should "get the 101 day challenge achievement" do
        assert @user.achievements.map(&:name).include?("101 Day Challenge")
      end
    end
    
    context "who does 6 months of continous yoga" do
      setup do
        Factory.create(:achievement, :name => "Six Month Challenge")
        
        streak_for @user, 6.months
        @user.update_progress(@user.lessons)
      end

      should "get the Six Month Challenge achievement" do
        assert @user.achievements.map(&:name).include?("Six Month Challenge")
      end
    end
    
    context "who does 1 year of continous yoga" do
      setup do
        Factory.create(:achievement, :name => "365 Day Challenge")
        
        streak_for @user, 1.year.to_i
        @user.update_progress(@user.lessons)
      end

      should "get the 365 day challenge achievement" do
        assert @user.achievements.map(&:name).include?("365 Day Challenge")
      end
    end
    
  end
end

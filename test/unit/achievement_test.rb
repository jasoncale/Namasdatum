require 'test_helper'

class AchievementTest < ActiveSupport::TestCase

  context "A user" do
    setup do
      @fred = Factory.create(:user, :username => "fred")
      @jim = Factory.create(:user, :username => "jim")
    end
    
    context "who does 30 straight days of yoga" do
      setup do
        Factory.create(:achievement, :name => "30 Day Challenge")
        
        streak_for @fred, 30.days
        @fred.update_progress(@fred.lessons)
      end

      should "get the 30 day challenge achievement" do
        assert @fred.achievements.map(&:name).include?("30 Day Challenge")
      end
      
      should "not be granted to jim just yet" do
        streak_for @jim, (@fred.longest_streak - 1).days
        @jim.update_progress(@jim.lessons)
        assert @jim.achievements.blank?
      end
    end
    
    context "who does 60 straight days of yoga" do
      setup do
        Factory.create(:achievement, :name => "60 Day Challenge")
        
        streak_for @fred, 60.days
        @fred.update_progress(@fred.lessons)
      end

      should "get the 60 day challenge achievement" do
        assert @fred.achievements.map(&:name).include?("60 Day Challenge")
      end
      
      should "not be granted to jim just yet" do
        streak_for @jim, (@fred.longest_streak - 1).days
        @jim.update_progress(@jim.lessons)
        assert @jim.achievements.blank?
      end
    end
    
    context "who does 90 straight days of yoga" do
      setup do
        Factory.create(:achievement, :name => "90 Day Challenge")
        
        streak_for @fred, 90.days
        @fred.update_progress(@fred.lessons)
      end

      should "get the 90 day challenge achievement" do
        assert @fred.achievements.map(&:name).include?("90 Day Challenge")
      end
      
      should "not be granted to jim just yet" do
        streak_for @jim, (@fred.longest_streak - 1).days
        @jim.update_progress(@jim.lessons)
        assert @jim.achievements.blank?
      end
    end
    
    context "who does 101 straight days of yoga" do
      setup do
        Factory.create(:achievement, :name => "101 Day Challenge")
        
        streak_for @fred, 101.days
        @fred.update_progress(@fred.lessons)
      end

      should "get the 101 day challenge achievement" do
        assert @fred.achievements.map(&:name).include?("101 Day Challenge")
      end
      
      should "not be granted to jim just yet" do
        streak_for @jim, (@fred.longest_streak - 1).days
        @jim.update_progress(@jim.lessons)
        assert @jim.achievements.blank?
      end
    end
    
    context "who does 6 months of continous yoga" do
      setup do
        Factory.create(:achievement, :name => "Six Month Challenge")
        
        streak_for @fred, 180.days
        @fred.update_progress(@fred.lessons)
      end

      should "get the Six Month Challenge achievement" do
        assert @fred.achievements.map(&:name).include?("Six Month Challenge")
      end
      
      should "not be granted to jim just yet" do
        streak_for @jim, (@fred.longest_streak - 1).days
        @jim.update_progress(@jim.lessons)
        assert @jim.achievements.blank?
      end
    end
    
    context "who does 1 year of continous yoga" do
      setup do
        Factory.create(:achievement, :name => "365 Day Challenge")
        streak_for @fred, 365.days
        @fred.update_progress(@fred.lessons)
      end

      should "get the 365 day challenge achievement" do
        assert @fred.achievements.map(&:name).include?("365 Day Challenge")
      end
      
      should "not be granted to jim just yet" do
        streak_for @jim, (@fred.longest_streak - 1).days
        @jim.update_progress(@jim.lessons)
        assert @jim.achievements.blank?
      end
    end
  end
end

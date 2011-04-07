require 'test_helper'

class StreakTest < ActiveSupport::TestCase
  
  context "calculating current streaks" do
    setup do
      @streak = Streak.new(7.days.ago)
    end

    context "streak that ended today" do
      setup do
        @streak.ended = Date.today
      end
      
      should "be current" do
        assert @streak.current?
      end
    end
    
    context "streak that ended yesterday" do
      setup do
        @streak.ended = Date.yesterday
      end
    
      should "still be current as user could add that streak today" do
        assert @streak.current?
      end
    end
    
    context "streak that ended two days ago" do
      setup do
        @streak.ended = 2.days.ago.to_date
      end
    
      should "not be current" do
        assert !@streak.current?
      end
    end
    
    context "streak that ended two days ago but has a double" do
      setup do
        @streak.ended = 2.days.ago.to_date
        @streak.double_on(3.days.ago)
      end
    
      should "be current" do
        assert @streak.current?
      end
    end
    
    context "streak that ended two days ago which has a double but a double already used in last 7 days" do
      setup do
        @streak.double_on(5.days.ago)
        @streak.double_on(3.days.ago)
        @streak.ended = 2.days.ago.to_date
        @streak.current?
      end
    
      should "have the last double used as 5.days.ago" do
        assert_equal(5.days.ago.to_date, @streak.double_last_used)
      end
    
      should "not be current" do
        assert !@streak.current?, "should not be current anymore"
      end
    end
    
  end

  context "calculating double classes" do
    setup do
      @streak = Streak.new(7.days.ago, Date.today)
    end
    
    context "double happens in 4 days ago" do
      setup do
        @streak.double_on(4.days.ago)
      end

      should "calculate that a double has happened in last 7 days" do
        assert @streak.double_in_last?(7.days)
      end
      
      should "calculate that a double hasn't happened in last 3 days" do
        assert_equal false, @streak.double_in_last?(3.days)
      end
    end
    
    context "double happened today" do
      setup do
        @streak.double_on(Date.today)
      end
      
      should "calculate that double has happened in last 3 days" do
        assert @streak.double_in_last?(3.days)
      end
    end
    
    context "multiple doubles happen in course of 7 days" do
      setup do
        @streak.double_on(2.days.ago)
        @streak.double_on(4.days.ago)
      end

      should "calculate that double has happened in last 7 days" do
        assert @streak.double_in_last?(7.days)
      end
      
      should "calculate that 2 double have happened" do
        assert_equal 2, @streak.doubles_in_last(7.days).count
      end
    end
    
  end
end
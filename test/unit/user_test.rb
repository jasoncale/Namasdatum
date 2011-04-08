require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context "Attempting to import history" do
    setup do
      stub_user_history('user_history_single_lesson')
    end
    
    context "mindbodyonline username missing" do
      setup do
        @user = Factory.create(:user, :mindbodyonline_user => '')
        @user.fetch_lesson_history        
      end

      should "not create any lessons" do
        assert_equal(0, @user.lessons.count)
      end
    end
    
    context "mindbodyonline password missing" do
      setup do
        @user = Factory.create(:user, :mindbodyonline_pw => '')
        @user.fetch_lesson_history        
      end

      should "not create any lessons" do
        assert_equal(0, @user.lessons.count)
      end
    end
  end
  
  context "Importing a single lesson" do
    setup do            
      stub_user_history('user_history_single_lesson')
      @user = Factory.create(:user)
      @user.fetch_lesson_history
    end
    
    should "record the lesson" do
      assert_equal(1, @user.lessons.count)
    end
  
    should "record the correct lesson time" do
      assert_equal(Time.zone.parse('2010-11-30 10:00:00'), @user.lessons.first.attended_at)
    end
    
    should "record the teacher" do
      assert_equal("Fran Rytlewski", @user.lessons.first.teacher.name)
    end
    
    should "record the studio" do
      assert_equal("Balham", @user.lessons.first.studio.name)
    end
  end
  
  context "Importing entire user history" do
    setup do
      stub_user_history('user_history')
      @user = Factory.create(:user)
      @user.fetch_lesson_history
    end
  
    should "record all the lessons" do
      assert_equal(128, @user.lessons.count)
    end
    
    should "only record Balham as a studio" do
      assert_equal(1, Studio.count)
      assert_equal("Balham", Studio.first.name)
    end
    
    context "and attempting to re-import without any new lessons" do
      setup do
        @imported = @user.fetch_lesson_history
      end
  
      should "return an empty array for imported lessons" do
        assert_equal(0, @imported.length)
      end
  
      should "not record anymore lessons" do
        assert_equal(128, @user.lessons.count)
      end
    end
    
    context "and attempting to re-import with any new lessons" do
      setup do
        stub_user_history('user_history_with_new_lesson')
        @imported = @user.fetch_lesson_history
      end
  
      should "return array of imported lessons" do
        assert_equal(1, @imported.length)
      end
      
      should "record just the new lesson" do
        assert_equal(129, @user.lessons.count)
      end
    end
    
  end
   
  context "Fetching user history from mindbodyonline.com" do
    setup do      
      stub_user_history('user_history')
      @user = Factory.create(:user)
      @imported = @user.fetch_lesson_history
    end
    
    should "return array of imported lessons" do
      assert_equal(128, @imported.length)
    end
    
    should "fetch the users entire lesson history" do
      assert_equal(128, @user.lessons.count)
    end
    
    should "set the highest streak to 30 days" do
      assert_equal 30, @user.longest_streak
    end
  end
  
  context "Username" do
    setup do
      @user = Factory.create(:user, :username => "Bobby")
    end

    should "be coverted to lowercase" do
      assert_equal("bobby", @user.username)
    end
    
    context "uniqueness" do
      setup do
        Factory.create(:user, :username => "Joe")      
      end

      should "be checked on creation" do
        assert_raise(ActiveRecord::RecordInvalid) { Factory.create(:user, :username => "Joe") }
      end
      
      should "be checked on update" do
        @user = Factory.create(:user, :username => "Frank") 
        @user.username = "Joe"
        @user.save
        
        assert_equal "must be unique", @user.errors[:username].first        
        assert_equal("frank", @user.reload.username)
      end
    end
  end

  context "Given a user who has attended class for last 3 days" do
    setup do
      @user = Factory.create(:user)
      streak_for @user, 3.days
      @user.update_progress(@user.lessons)
    end

    should "calculate current streak length as 3 days" do
      assert_equal(3, @user.current_streak)
    end
    
    context "a day goes by and the user doesn't practice" do
      setup do
        # move forward two days to ensure 
        # that no practice could have happened
        Timecop.travel(Time.zone.now + 1.days)
        
        @user.update_progress(@user.lessons)
      end
    
      should "calculate current streak length as 0" do
        assert_equal(0, @user.current_streak)
      end
    end
  end
  
  context "Given a user who practices every day over 7 days" do
    setup do
      @user = Factory.create(:user)
      streak_for @user, 7.days
      @user.update_progress(@user.lessons)
    end
    
    should "calculate current streak length as 7" do
      assert_equal(7, @user.current_streak)
    end
    
    should "have 7 recorded lessons" do
      assert_equal(7, @user.lessons.streak_recorded.count)
    end
  
    context "with a double included" do
      setup do
        # do the 3pm class as well as 10am
        attend_class_time(@user, 1.day.ago, 15)
        @user.update_progress(@user.lessons.reload)
      end
  
      should "calculate current streak length as 7" do
        assert_equal(7, @user.current_streak)
      end
      
      should "have 8 recorded lessons" do
        assert_equal(8, @user.lessons.streak_recorded.count)
      end
    end
  end
  
  context "Given a user who practices over 7 days missing a day has done a double" do
    setup do
      @user = Factory.create(:user)
      streak_for @user, 7.days
      
      # remove 3rd day
      @user.lessons[2].destroy
      
      # double on the 5th day
      attend_class_time(@user, 2.days.ago, 15)
      
      @user.lessons.reload
      @user.update_progress(@user.lessons)  
    end
    
    should "have 7 lessons recorded" do
      assert_equal(7, @user.lessons.count)
    end

    should "currently streak length of 7" do
      assert_equal(7, @user.current_streak)
    end
  end
    
  context "praciticing with two missing days in one week two doubles" do
    setup do
      @user = Factory.create(:user)
      streak_for @user, 7.days
      
      # remove 2rd & 4th day
      @user.lessons[1].destroy
      @user.lessons[3].destroy

      # double on the 3rd & 5th day
      attend_class_time(@user, 5.days.ago, 15)
      attend_class_time(@user, 3.days.ago, 15)
      
      @user.lessons.reload
      @user.update_progress(@user.lessons)
    end
    
    should "have a practiced yesterday" do
      assert_equal Date.yesterday, @user.lessons.order(:attended_at).last.attended_at.to_date
    end
    
    should "have 7 lessons recorded" do
      assert_equal(7, @user.lessons.count)
    end

    should "currently streak length of 1" do
      assert_equal(1, @user.current_streak)
    end
  end
end

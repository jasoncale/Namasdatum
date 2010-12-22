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
        @user.fetch_lesson_history
      end
  
      should "not record anymore lessons" do
        assert_equal(128, @user.lessons.count)
      end
    end
    
    context "and attempting to re-import without any new lessons" do
      setup do
        stub_user_history('user_history_with_new_lesson')
        @user.fetch_lesson_history
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
      @user.fetch_lesson_history
    end
  
    should "fetch the users entire lesson history" do
      assert_equal(128, @user.lessons.count)
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
end

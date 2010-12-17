require 'test_helper'

class LessonTest < ActiveSupport::TestCase
  
  context "Given an existing lesson" do
    setup do
      @time = Time.zone.now
      @user = Factory.create(:user)
      @lesson = Lesson.create(:attended_at => @time, :user => @user)
    end
  
    context "attempting to create lesson at the same time of attendence" do
      setup do
        @duplicate = Lesson.create(:attended_at => @time, :user => @user)
      end

      should "raise error" do
        assert_equal "a user cannot attendee the same lesson twice", @duplicate.errors[:attended_at].first
      end

      should "not create lesson record" do
        assert_equal(1, Lesson.count)
      end
    end
  end  
  
end

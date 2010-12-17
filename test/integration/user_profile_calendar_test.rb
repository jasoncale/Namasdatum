require 'test_helper'

class UserProfileCalendarTest < ActionDispatch::IntegrationTest
  
  context "User profile calendar" do
    setup do
      @user = sign_up(:username => "Kevin")
      
      # 12th December 2010 at 10AM
      Timecop.travel(Time.local(2010, 12, 17, 10, 0, 0)) 
      @current_time = Time.zone.now
      visit user_path(@user)
    end
    
    should "see current month" do
      within(".calendar") do
        assert page.has_content?(@current_time.strftime("%B"))
      end
    end
    
    should "see each day in the month" do
      within(".calendar ol") do
        assert page.has_css?('li', :count => Time.days_in_month(@current_time.month))
      end
    end
    
    context "with a single lesson" do
      setup do
        @lesson = Factory.create(:lesson, :user => @user, :attended_at => @current_time.yesterday)
        visit user_path(@user)
      end
      
      should "be marked on the calendar as attended" do  
        within(".calendar ol") do
          assert page.has_css?('li.attended', :count => 1)
        end
      end
    end
    
    context "lesson description under date" do
      setup do
        @lesson = Factory.create(:lesson, :user => @user, :attended_at => @current_time.yesterday)
        visit user_path(@user)
      end

      should "be listed under the correct day/date" do
        within(".calendar ol li.attended") do
          assert page.has_css?('h3.date', :with => "16")
        end
      end

      should "have .lesson element" do
        within(".calendar ol li.attended") do
          assert page.has_css?('.lesson', :count => 1)
        end
      end
      
      should "list the teacher" do
        within(".calendar ol li.attended .lesson") do
          assert page.has_content?(@lesson.teacher.name)
        end
      end
      
      should "list the class time" do
        within(".calendar ol li.attended .lesson") do
          assert page.has_content?("10:00 AM")
        end        
      end
    end
      
  end
end

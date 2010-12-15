require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context "Importing a single lesson" do
    setup do            
      @user = User.create!
      @user.record_lessons(Nokogiri::HTML(import_html('single_lesson_import')))
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
      @user = User.create!
      @user.record_lessons(Nokogiri::HTML(import_html('entire_lesson_import')))
    end
  
    should "record all the lessons" do
      assert_equal(127, @user.lessons.count)
    end
    
    should "only record Balham as a studio" do
      assert_equal(1, Studio.count)
      assert_equal("Balham", Studio.first.name)
    end
  end
  
  context "Fetching user history from mindbodyonline.com" do
    setup do      
      WebMock.allow_net_connect!
    
      # stub_request(:get, "https://clients.mindbodyonline.com/ASP/my_vh.asp?tabID=2").to_return(
      #   :body => File.new(File.join(Rails.root, "/test/fixtures/", "sample_user_history.html")), 
      #   :status => 200
      # )
        
      # To run this currently you will need Jase's username and password which isn't in the repo :)
        
      @user = User.create(:mindbodyonline_user => "user", :mindbodyonline_pw => "pass")
      @user.fetch_lesson_history
    end

    should "fetch the users entire lesson history" do
      assert_equal(128, @user.lessons.count)
    end
  end
  
end

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context "Importing a single lesson" do
    setup do            
      @user = User.create!
      @user.record_lessons(Nokogiri::HTML(import_html('user_history_single_lesson')))
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
      @user.record_lessons(Nokogiri::HTML(import_html('user_history')))
    end
  
    should "record all the lessons" do
      assert_equal(129, @user.lessons.count)
    end
    
    should "only record Balham as a studio" do
      assert_equal(1, Studio.count)
      assert_equal("Balham", Studio.first.name)
    end
    
    context "and attempting to re-import without any new lessons" do
      setup do
        @user.record_lessons(Nokogiri::HTML(import_html('user_history')))
      end
  
      should "not record anymore lessons" do
        assert_equal(129, @user.lessons.count)
      end
    end
    
  end
   
  context "Fetching user history from mindbodyonline.com" do
    setup do      
      # stub home page
      stub_request(:get, "https://clients.mindbodyonline.com/ASP/home.asp?studioid=1134").to_return(
        html_body('app_index')
      )
      
      # stub session creation post
      stub_request(:post, "https://clients.mindbodyonline.com/ASP/home.asp?studioid=1134")
      
      # stub logging in
      stub_request(:post, "https://clients.mindbodyonline.com/ASP/login_p.asp")
      
      # stub getting user history
      stub_request(:get, "https://clients.mindbodyonline.com/ASP/my_vh.asp?tabID=2").to_return(
        html_body('user_history')
      )
      
      @user = User.create(:mindbodyonline_user => "user", :mindbodyonline_pw => "pass")
      @user.fetch_lesson_history
    end
  
    should "fetch the users entire lesson history" do
      assert_equal(129, @user.lessons.count)
    end
  end
  
  private
  
  def import_html(filename)
    return File.read(File.join(File.expand_path('../../test/fixtures/html_content'), "#{filename}.html"))
  end
  
  def html_body(filename)
    {
      :body => import_html(filename),
      :headers => { "Content-Type" => "text/html" }
    }
  end

end

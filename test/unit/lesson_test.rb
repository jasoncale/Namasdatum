require 'test_helper'
require 'shoulda'
require 'nokogiri'

class LessonTest < ActiveSupport::TestCase

  context "Importing a single lesson" do
    setup do            
      Lesson.import(import_html('single_lesson_import'))
    end
    
    should "record the lesson" do
      assert_equal(1, Lesson.count)
    end

    should "record the correct lesson time" do
      assert_equal(Time.zone.parse('2010-11-30 10:00:00'), Lesson.first.attended_at)
    end
    
    should "record the teacher" do
      assert_equal("Fran Rytlewski", Lesson.first.teacher.name)
    end
    
    should "record the studio" do
      assert_equal("Balham", Lesson.first.studio.name)
    end
  end
  
  context "Importing entire user history" do
    setup do
      Lesson.import(import_html('entire_lesson_import'))
    end

    should "record all the lessons" do
      assert_equal(127, Lesson.count)
    end
    
    should "only record Balham as a studio" do
      assert_equal(1, Studio.count)
      assert_equal("Balham", Studio.first.name)
    end
  end
    
end

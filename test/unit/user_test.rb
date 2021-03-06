require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context "Attempting to import history" do
    setup do
      stub_user_history('user_history_single_lesson')
    end

    context "mindbodyonline username missing" do
      setup do
        @user = Factory.create(:user, :mindbodyonline_user => '')
        @user.process_data
      end

      should "not create any lessons" do
        assert_equal(0, @user.lessons.count)
      end
    end

    context "mindbodyonline password missing" do
      setup do
        @user = Factory.create(:user, :mindbodyonline_pw => '')
        @user.process_data
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
      @user.process_data
    end

    should "record the lesson" do
      assert_equal(1, @user.lessons.count)
    end

    should "record the correct lesson time in the database (as UTC)" do
      assert_equal(Time.utc(2011,7,26,9), @user.lessons.first['attended_at'])
    end

    should "present the time in the britsh summer time" do
      assert_equal(Time.utc(2011,7,26,9).in_time_zone, @user.lessons.first.attended_at)
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
      @user.process_data
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
        @imported = @user.process_data
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
        @imported = @user.process_data
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
      @imported = @user.process_data
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

  context "Foursquare auto checkins" do
    setup do
      @balham = Factory.create(:studio, :name => "Balham", :foursquare_venue_id => "VENUE_BALHAM")
      @fulham = Factory.create(:studio, :name => "Fulham", :foursquare_venue_id => "VENUE_FULHAM")
    end

    context "User with foursquare access token" do
      setup do
        @user = Factory.create(:user, :foursquare_access_token => "ABC")
      end

      context "class a single studio" do
        setup do
          attend_class_and_shift_time_to_after_begun(@user, Date.today, 15)
          expect_foursquare_checkin_for(@balham)
        end

        should "record a checkin" do
          assert_equal 1, @user.process_geo_checkins.count
        end
      end

      context "two classes at a single studio" do
        setup do
          attend_class_time(@user, Date.today, 10)
          attend_class_and_shift_time_to_after_begun(@user, Date.today, 15)
          expect_foursquare_checkin_for(@balham)
        end

        should "only record a single checkin" do
          assert_equal 1, @user.process_geo_checkins.count
        end
      end

      context "two classes, different studios" do
        setup do
          attend_class_time(@user, Date.today, 10, @balham)
          attend_class_and_shift_time_to_after_begun(@user, Date.today, 15, @fulham)
          expect_foursquare_checkin_for(@balham)
          expect_foursquare_checkin_for(@fulham)
        end

        should "record two checkins" do
          assert_equal 2, @user.process_geo_checkins.count
        end

        should "record checkin for balham" do
          assert @user.process_geo_checkins.map(&:venue).include?("Balham")
        end

        should "record checkin for fulham" do
          assert @user.process_geo_checkins.map(&:venue).include?("Fulham")
        end
      end
    end

    context "User with foursquare access token who has already manually checked in to studio" do
      setup do
        @user = Factory.create(:user, :foursquare_access_token => "ABC")
        checkin = stub_foursquare_user_checkin(@user, @balham)
        stub_foursquare_checkins([checkin])
        attend_class_time(@user, Date.today, 15)
      end

      should "not create a checkin" do
        assert_equal 0, @user.process_geo_checkins.count
      end

      should "know that user has already checked in" do
        assert @user.foursquare_already_checked_in_at?(@balham)
      end
    end

    context "User without foursqaure access token" do
      setup do
        @user = Factory.create(:user)
        manual_checkin = stub_foursquare_user_checkin(@user, @balham)

        attend_class_time(@user, Date.today, 15)
      end

      should "not have foursquare access token" do
        assert_nil @user.foursquare_access_token
      end

      should "not create a checkin" do
        assert_equal 0, @user.process_geo_checkins.count
      end
    end
  end

  context "Gowalla auto checkins" do
    setup do
      @balham = Factory.create(:studio, :name => "Balham", :gowalla_venue_id => "VENUE_BALHAM", :lat => 123, :lng => 123)
      @fulham = Factory.create(:studio, :name => "Fulham", :gowalla_venue_id => "VENUE_FULHAM", :lat => 456, :lng => 456)
    end

    context "User with gowalla access token" do
      setup do
        @user = Factory.create(:user, :gowalla_access_token => "ABC", :gowalla_username => "jimmy")
        stub_gowalla_checkins(@user, [])
      end

      context "class a single studio" do
        setup do
          attend_class_and_shift_time_to_after_begun(@user, Date.today, 15)
          expect_gowalla_checkin_for(@user, @balham)
        end

        should "record a checkin" do
          assert_equal 1, @user.process_geo_checkins.count
        end
      end

      context "two classes at a single studio" do
        setup do
          attend_class_time(@user, Date.today, 10)
          attend_class_and_shift_time_to_after_begun(@user, Date.today, 15)
          expect_gowalla_checkin_for(@user, @balham)
        end

        should "only record a single checkin" do
          assert_equal 1, @user.process_geo_checkins.count
        end
      end

      context "two classes, different studios" do
        setup do
          attend_class_time(@user, Date.today, 10, @balham)
          attend_class_and_shift_time_to_after_begun(@user, Date.today, 15, @fulham)
          expect_gowalla_checkin_for(@user, @balham)
          expect_gowalla_checkin_for(@user, @fulham)
        end

        should "record a two checkins" do
          assert_equal 2, @user.process_geo_checkins.count
        end
      end
    end

    context "User with gowalla access token who has already manually checked in to studio" do
      setup do
        @user = Factory.create(:user, :gowalla_access_token => "ABC", :gowalla_username => "jimmy")
        stub_existing_gowalla_checkin_for(@user, @balham)
        attend_class_and_shift_time_to_after_begun(@user, Date.today, 15)
      end

      should "not create a checkin" do
        assert_equal 0, @user.process_geo_checkins.count
      end
    end

    context "User without gowalla access token" do
      setup do
        @user = Factory.create(:user)
        attend_class_and_shift_time_to_after_begun(@user, Date.today, 15)
      end

      should "not have gowalla access token" do
        assert_nil @user.gowalla_access_token
      end

      should "not be gowalla enabled" do
        assert !@user.gowalla_enabled?
      end

      should "not create a checkin" do
        assert_equal 0, @user.process_geo_checkins.count
      end
    end
  end

  context "Booking a class ahead of time and attempting auto checkin" do
    setup do
      @balham = Factory.create(:studio,
        :name => "Balham",
        :gowalla_venue_id => "VENUE_BALHAM",
        :lat => 123,
        :lng => 123,
        :foursquare_venue_id => "VENUE_BALHAM"
      )

      @user = Factory.create(:user,
        :gowalla_access_token => "ABC",
        :gowalla_username => "jimmy",
        :foursquare_access_token => "ABC"
      )

      @lesson = attend_class_and_shift_time_to_after_begun(@user, Date.today, 15)
    end

    context "before the class has started" do
      setup do
        Timecop.travel(@lesson.attended_at - 1.hour)

        stub_gowalla_checkins(@user)
        stub_foursquare_checkins

        expect_no_foursquare_checkin
        expect_no_gowalla_checkin(@user)
      end

      should "not create a checkin" do
        assert_equal 0, @user.process_geo_checkins.count
      end
    end

    context "once the class has started" do
      setup do
        stub_gowalla_checkins(@user)
        stub_foursquare_checkins

        expect_gowalla_checkin_for(@user, @balham)
        expect_foursquare_checkin_for(@balham)
      end

      should "create the checkins" do
        assert_equal 2, @user.process_geo_checkins.count
      end
    end
  end


end

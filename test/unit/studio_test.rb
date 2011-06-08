require 'test_helper'

class StudioTest < ActiveSupport::TestCase

  context "Studio as a gowalla venue" do
    setup do
      @studio = Factory.create(:studio)
    end

    should "not have venue_id yet" do
      assert @studio.gowalla_venue_id.blank?
    end
    
    should "not have lng" do
      assert @studio.lng.blank?
    end
    
    should "not have lat" do
      assert @studio.lat.blank?
    end
    
    context "adding gowalla venue id without lat lng attributes" do
      setup do
        @studio.gowalla_venue_id = '123'
        @studio.save
      end
      
      should "not be valid" do
        assert !@studio.valid?
      end
      
      should "require lat" do
        assert_equal ["is required when Gowalla venue id is present"], @studio.errors[:lat]
      end      

      should "require lng" do
        assert_equal ["is required when Gowalla venue id is present"], @studio.errors[:lng]
      end      
    end
    
  end
  

end
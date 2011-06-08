class Studio < ActiveRecord::Base
  has_many :lessons
  validates_uniqueness_of :name
  
  validates_presence_of :lat, :lng, :message => "is required when Gowalla venue id is present", :if => :gowalla_venue?

  def gowalla_venue?
    gowalla_venue_id.present? 
  end
  
  def foursquare_venue?
    foursquare_venue_id.present?
  end
end

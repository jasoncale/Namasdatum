class AddFoursquareVenueToStudio < ActiveRecord::Migration
  def self.up
    add_column :studios, :foursquare_venue_id, :string
  
    Studio.find_or_create_by_name("Balham").update_attribute(:foursquare_venue_id, "4af6cafbf964a5207f0322e3")
    Studio.find_or_create_by_name("Fulham").update_attribute(:foursquare_venue_id, "4c8a2ca752a98cfa29f929e9")
  end

  def self.down
    remove_column :studios, :foursquare_venue_id
  end
end
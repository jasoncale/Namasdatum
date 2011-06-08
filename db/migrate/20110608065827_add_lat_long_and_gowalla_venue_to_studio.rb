class AddLatLongAndGowallaVenueToStudio < ActiveRecord::Migration
  def self.up
    add_column :studios, :gowalla_venue_id, :string
    add_column :studios, :lat, :decimal, :precision => 15, :scale => 10
    add_column :studios, :lng, :decimal, :precision => 15, :scale => 10
  
    Studio.find_or_create_by_name("Balham").update_attributes(
      :gowalla_venue_id => "500529",
      :lat => 51.4443069868,
      :lng => -0.1514809993
    )
  end

  def self.down
    remove_column :studios, :lng
    remove_column :studios, :lat
    remove_column :studios, :gowalla_venue_id
  end
end
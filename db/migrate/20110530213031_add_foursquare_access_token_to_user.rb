class AddFoursquareAccessTokenToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :foursquare_access_token, :string
  end

  def self.down
    remove_column :users, :foursquare_access_token
  end
end
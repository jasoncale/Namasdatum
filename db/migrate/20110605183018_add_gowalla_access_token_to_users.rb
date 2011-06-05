class AddGowallaAccessTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gowalla_access_token, :string
  end

  def self.down
    remove_column :users, :gowalla_access_token
  end
end
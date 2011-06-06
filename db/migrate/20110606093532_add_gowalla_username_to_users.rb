class AddGowallaUsernameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gowalla_username, :string
  end

  def self.down
    remove_column :users, :gowalla_username
  end
end
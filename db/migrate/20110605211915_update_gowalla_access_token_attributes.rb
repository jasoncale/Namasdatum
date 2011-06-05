class UpdateGowallaAccessTokenAttributes < ActiveRecord::Migration
  def self.up
    add_column :users, :gowalla_refresh_token, :string
    add_column :users, :gowalla_access_token_expires_at, :datetime
  end

  def self.down
    remove_column :users, :gowalla_access_token_expires_at
    remove_column :users, :gowalla_refresh_token
  end
end
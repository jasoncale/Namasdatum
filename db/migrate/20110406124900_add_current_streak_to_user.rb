class AddCurrentStreakToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :current_streak, :integer, :default => 0
  end

  def self.down
    remove_column :users, :current_streak
  end
end
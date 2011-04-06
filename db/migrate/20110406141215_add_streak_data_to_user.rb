class AddStreakDataToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :streak_start, :date
    add_column :users, :streak_end, :date
    add_column :users, :longest_streak, :integer, :default => 0
    add_column :users, :longest_streak_start, :date
    add_column :users, :longest_streak_end, :date
  end

  def self.down
    remove_column :users, :longest_streak_end
    remove_column :users, :longest_streak_start
    remove_column :users, :longest_streak
    remove_column :users, :streak_end
    remove_column :users, :streak_start
  end
end
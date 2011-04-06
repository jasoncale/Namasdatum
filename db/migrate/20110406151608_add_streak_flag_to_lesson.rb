class AddStreakFlagToLesson < ActiveRecord::Migration
  def self.up
    add_column :lessons, :streak_recorded, :boolean, :default => false
  end

  def self.down
    remove_column :lessons, :streak_recorded
  end
end
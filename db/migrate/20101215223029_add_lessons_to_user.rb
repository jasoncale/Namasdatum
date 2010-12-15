class AddLessonsToUser < ActiveRecord::Migration
  def self.up
    add_column :lessons, :user_id, :integer
  end

  def self.down
    remove_column :lessons, :user_id
  end
end
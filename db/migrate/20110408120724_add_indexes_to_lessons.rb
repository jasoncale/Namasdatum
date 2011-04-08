class AddIndexesToLessons < ActiveRecord::Migration
  def self.up
    add_index :lessons, :teacher_id
    add_index :lessons, :studio_id
    add_index :lessons, :user_id
  end

  def self.down
    remove_index :lessons, :user_id
    remove_index :lessons, :studio_id    
    remove_index :lessons, :teacher_id
  end
end
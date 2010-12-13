class CreateLessons < ActiveRecord::Migration
  def self.up
    create_table :lessons do |t|
      t.datetime :attended_at
      t.timestamps
    end
  end

  def self.down
    drop_table :lessons
  end
end

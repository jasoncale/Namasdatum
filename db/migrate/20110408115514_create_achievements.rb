class CreateAchievements < ActiveRecord::Migration
  def self.up
    create_table :achievements do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
    
    create_table :achievements_users, :id => false do |t|
      t.integer :user_id
      t.integer :achievement_id
    end
    
    add_index :achievements_users, :user_id
    add_index :achievements_users, :achievement_id
  end

  def self.down
    remove_index :achievements_users, :achievement_id
    remove_index :achievements_users, :user_id
    drop_table :achievements
  end
end
class CreateTeachers < ActiveRecord::Migration
  def self.up
    create_table :teachers do |t|
      t.string :name

      t.timestamps
    end
    
    add_column :lessons, :teacher_id, :integer
  end

  def self.down
    remove_column :lessons, :techer_id
    drop_table :teachers
  end
end
class CreateStudios < ActiveRecord::Migration
  def self.up
    create_table :studios do |t|
      t.string :name

      t.timestamps
    end

    add_column :lessons, :studio_id, :integer
  end

  def self.down
    remove_column :lessons, :studio_id
    drop_table :studios
  end
end
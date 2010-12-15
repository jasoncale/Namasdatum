class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :mindbodyonline_user
      t.string :mindbodyonline_pw

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110530225230) do

  create_table "achievements", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "achievements_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "achievement_id"
  end

  add_index "achievements_users", ["achievement_id"], :name => "index_achievements_users_on_achievement_id"
  add_index "achievements_users", ["user_id"], :name => "index_achievements_users_on_user_id"

  create_table "lessons", :force => true do |t|
    t.datetime "attended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "teacher_id"
    t.integer  "studio_id"
    t.integer  "user_id"
    t.boolean  "streak_recorded", :default => false
  end

  add_index "lessons", ["studio_id"], :name => "index_lessons_on_studio_id"
  add_index "lessons", ["teacher_id"], :name => "index_lessons_on_teacher_id"
  add_index "lessons", ["user_id"], :name => "index_lessons_on_user_id"

  create_table "studios", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "foursquare_venue_id"
  end

  create_table "teachers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                  :default => "", :null => false
    t.string   "encrypted_password",      :limit => 128, :default => "", :null => false
    t.string   "password_salt",                          :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "mindbodyonline_user"
    t.string   "mindbodyonline_pw"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.integer  "current_streak",                         :default => 0
    t.date     "streak_start"
    t.date     "streak_end"
    t.integer  "longest_streak",                         :default => 0
    t.date     "longest_streak_start"
    t.date     "longest_streak_end"
    t.string   "foursquare_access_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

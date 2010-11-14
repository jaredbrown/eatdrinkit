# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101113164845) do

  create_table "deals", :force => true do |t|
    t.string   "venue_id"
    t.string   "subject",    :limit => 60
    t.string   "offer",      :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", :force => true do |t|
    t.string   "venue_id",   :null => false
    t.string   "latitude",   :null => false
    t.string   "longitude",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", :force => true do |t|
    t.string   "venue_id"
    t.string   "menu_item",  :limit => 80
    t.integer  "liked",      :limit => 1
    t.integer  "user_id"
    t.integer  "place_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username",                  :limit => 30
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "address",                   :limit => 120
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "confirmation_code",         :limit => 40
    t.string   "password_reset_code",       :limit => 40
    t.string   "state",                                    :default => "passive"
    t.datetime "confirmed_at"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

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

ActiveRecord::Schema.define(:version => 20081009202043) do

  create_table "audiographies", :force => true do |t|
    t.string  "title",     :limit => 500
    t.string  "url_title", :limit => 500
    t.integer "user_id"
  end

  create_table "communiques", :force => true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "communiques", ["user_id"], :name => "user_id"

  create_table "file_uploads", :force => true do |t|
    t.text "local_path"
  end

  create_table "logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.string   "item_class",          :limit => 50
    t.string   "event"
    t.text     "exception_backtrace"
    t.text     "exception_message"
    t.datetime "time"
    t.text     "message"
  end

  create_table "suggestions", :force => true do |t|
    t.text "body"
  end

  create_table "tracks", :force => true do |t|
    t.text     "url"
    t.string   "title",          :limit => 500
    t.string   "artist",         :limit => 500
    t.text     "comment"
    t.integer  "audiography_id"
    t.string   "file_upload_id", :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "permalink"
    t.integer  "sort_order",                    :default => 0
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "admin",                                   :default => 0
    t.integer  "fake",                                    :default => 0
  end

end

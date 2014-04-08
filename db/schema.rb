# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20140408090650) do

  create_table "contents", :force => true do |t|
    t.integer  "section_id"
    t.string   "title"
    t.string   "caption"
    t.string   "sub_caption"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contents", ["section_id"], :name => "section_id_UNIQUE", :unique => true

  create_table "media", :force => true do |t|
    t.integer  "section_id"
    t.integer  "media_type"
    t.string   "title"
    t.string   "caption"
    t.integer  "caption_align"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
    t.integer  "position"
  end

  create_table "sections", :force => true do |t|
    t.integer  "story_id"
    t.integer  "type_id"
    t.string   "title"
    t.integer  "position"
    t.string   "audio_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "has_marker"
  end

  create_table "stories", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.string   "author"
    t.string   "media_author"
    t.boolean  "published"
    t.datetime "published_at"
    t.float    "latitude",     :limit => 10
    t.float    "longitude",    :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stories_users", :force => true do |t|
    t.integer "story_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.integer  "role",                   :default => 0,  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "nickname"
    t.string   "avatar"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

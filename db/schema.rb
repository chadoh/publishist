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

ActiveRecord::Schema.define(:version => 20101207020010) do

  create_table "attendances", :force => true do |t|
    t.integer  "meeting_id"
    t.integer  "person_id"
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "person_name"
  end

  create_table "compositions", :force => true do |t|
    t.text     "title"
    t.text     "body"
    t.string   "author_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id"
    t.string   "author_email"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  create_table "meetings", :force => true do |t|
    t.datetime "when"
    t.string   "question"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packets", :force => true do |t|
    t.integer  "meeting_id"
    t.integer  "composition_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_salt"
    t.string   "encrypted_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "verified",             :default => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "people", ["confirmation_token"], :name => "index_people_on_confirmation_token", :unique => true
  add_index "people", ["email"], :name => "index_people_on_email", :unique => true
  add_index "people", ["reset_password_token"], :name => "index_people_on_reset_password_token", :unique => true

  create_table "ranks", :force => true do |t|
    t.integer  "person_id"
    t.integer  "rank_type"
    t.datetime "rank_start"
    t.datetime "rank_end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

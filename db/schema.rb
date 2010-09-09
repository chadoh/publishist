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

ActiveRecord::Schema.define(:version => 20100907110927) do

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

  create_table "people", :force => true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "salt"
    t.string   "encrypted_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "verified",           :default => false
  end

  create_table "ranks", :force => true do |t|
    t.integer  "person_id"
    t.integer  "rank_type"
    t.datetime "rank_start"
    t.datetime "rank_end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.integer  "person_id"
    t.string   "ip_address"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "compositions", "people", :name => "compositions_author_id_fk", :column => "author_id"

end

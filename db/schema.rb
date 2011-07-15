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

ActiveRecord::Schema.define(:version => 20110712105532) do

  create_table "attendees", :force => true do |t|
    t.integer  "meeting_id"
    t.integer  "person_id"
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "person_name"
  end

  create_table "cover_arts", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "magazines", :force => true do |t|
    t.string   "title"
    t.string   "nickname"
    t.datetime "accepts_submissions_from"
    t.datetime "accepts_submissions_until"
    t.datetime "published_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count_of_scores",           :default => 0
    t.integer  "sum_of_scores",             :default => 0
    t.string   "cached_slug"
  end

  add_index "magazines", ["cached_slug"], :name => "index_magazines_on_cached_slug", :unique => true

  create_table "meetings", :force => true do |t|
    t.datetime "datetime"
    t.string   "question"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "magazine_id"
  end

  create_table "packlets", :force => true do |t|
    t.integer  "meeting_id"
    t.integer  "submission_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.integer  "magazine_id"
    t.integer  "position"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "email"
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
    t.string   "password_salt"
    t.string   "cached_slug"
  end

  add_index "people", ["cached_slug"], :name => "index_people_on_cached_slug", :unique => true
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

  create_table "scores", :force => true do |t|
    t.integer  "amount"
    t.integer  "attendee_id"
    t.integer  "packlet_id"
    t.boolean  "entered_by_coeditor", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "submissions", :force => true do |t|
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
    t.integer  "state",              :limit => 8, :default => 0
    t.string   "cached_slug"
    t.integer  "page_id"
    t.integer  "position"
  end

  add_index "submissions", ["cached_slug"], :name => "index_submissions_on_cached_slug", :unique => true

  add_foreign_key "cover_arts", "pages", :name => "cover_arts_page_id_fk"

  add_foreign_key "pages", "magazines", :name => "pages_magazine_id_fk", :dependent => :delete

  add_foreign_key "submissions", "pages", :name => "submissions_page_id_fk", :dependent => :nullify

end

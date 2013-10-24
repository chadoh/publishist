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

ActiveRecord::Schema.define(:version => 20131003000738) do

  create_table "abilities", :force => true do |t|
    t.string   "key"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attendees", :force => true do |t|
    t.integer  "meeting_id"
    t.integer  "person_id"
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "person_name"
  end

  create_table "cover_arts", :force => true do |t|
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
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "editors_notes", :force => true do |t|
    t.integer  "page_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

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
    t.string   "slug"
    t.boolean  "notification_sent",         :default => false
    t.string   "pdf_file_name"
    t.string   "pdf_content_type"
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.string   "cover_art_file_name"
    t.string   "cover_art_content_type"
    t.integer  "cover_art_file_size"
    t.datetime "cover_art_updated_at"
    t.integer  "publication_id"
  end

  add_index "magazines", ["slug"], :name => "index_magazines_on_cached_slug", :unique => true

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
    t.boolean  "verified",               :default => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "password_salt"
    t.string   "slug"
    t.integer  "primary_publication_id"
  end

  add_index "people", ["confirmation_token"], :name => "index_people_on_confirmation_token", :unique => true
  add_index "people", ["email"], :name => "index_people_on_email", :unique => true
  add_index "people", ["reset_password_token"], :name => "index_people_on_reset_password_token", :unique => true
  add_index "people", ["slug"], :name => "index_people_on_cached_slug", :unique => true

  create_table "position_abilities", :force => true do |t|
    t.integer  "position_id"
    t.integer  "ability_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "position_abilities", ["ability_id"], :name => "index_position_abilities_on_ability_id"
  add_index "position_abilities", ["position_id"], :name => "index_position_abilities_on_position_id"

  create_table "positions", :force => true do |t|
    t.integer  "magazine_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pseudonyms", :force => true do |t|
    t.string   "name"
    t.boolean  "link_to_profile", :default => true
    t.integer  "submission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "publication_details", :force => true do |t|
    t.integer "publication_id"
    t.text    "about"
    t.text    "meetings_info"
    t.string  "address"
    t.float   "latitude"
    t.float   "longitude"
  end

  create_table "publications", :force => true do |t|
    t.string   "subdomain",     :null => false
    t.string   "name"
    t.string   "tagline"
    t.string   "custom_domain"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "publications", ["custom_domain"], :name => "index_publications_on_custom_domain", :unique => true
  add_index "publications", ["subdomain"], :name => "index_publications_on_subdomain", :unique => true

  create_table "roles", :force => true do |t|
    t.integer  "person_id"
    t.integer  "position_id"
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

  create_table "staff_lists", :force => true do |t|
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "submissions", :force => true do |t|
    t.text     "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer  "state",              :limit => 8, :default => 0
    t.string   "slug"
    t.integer  "page_id"
    t.integer  "position"
    t.integer  "magazine_id"
    t.integer  "publication_id"
  end

  add_index "submissions", ["slug"], :name => "index_submissions_on_cached_slug", :unique => true

  create_table "table_of_contents", :force => true do |t|
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "cover_arts", "pages", :name => "cover_arts_page_id_fk"

  add_foreign_key "editors_notes", "pages", :name => "editors_notes_page_id_fk"

  add_foreign_key "magazines", "publications", :name => "magazines_publication_id_fk"

  add_foreign_key "pages", "magazines", :name => "pages_magazine_id_fk", :dependent => :delete

  add_foreign_key "people", "publications", :name => "people_primary_publication_id_fk", :column => "primary_publication_id"

  add_foreign_key "position_abilities", "abilities", :name => "position_abilities_ability_id_fk"
  add_foreign_key "position_abilities", "positions", :name => "position_abilities_position_id_fk"

  add_foreign_key "positions", "magazines", :name => "positions_magazine_id_fk"

  add_foreign_key "pseudonyms", "submissions", :name => "pseudonyms_submission_id_fk", :dependent => :delete

  add_foreign_key "publication_details", "publications", :name => "publication_details_publication_id_fk"

  add_foreign_key "roles", "people", :name => "roles_person_id_fk"
  add_foreign_key "roles", "positions", :name => "roles_position_id_fk"

  add_foreign_key "staff_lists", "pages", :name => "staff_lists_page_id_fk"

  add_foreign_key "submissions", "magazines", :name => "submissions_magazine_id_fk"
  add_foreign_key "submissions", "pages", :name => "submissions_page_id_fk", :dependent => :nullify
  add_foreign_key "submissions", "publications", :name => "submissions_publication_id_fk"

  add_foreign_key "table_of_contents", "pages", :name => "table_of_contents_page_id_fk"

end

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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140425095448) do

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "metrics", force: true do |t|
    t.string   "title"
    t.string   "key"
    t.text     "data_set"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metrics", ["key"], name: "index_metrics_on_key", unique: true

  create_table "pictures", force: true do |t|
    t.text     "src_url"
    t.text     "dst_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "transformtaion"
    t.datetime "last_access_time"
  end

  add_index "pictures", ["src_url", "transformtaion"], name: "index_pictures_on_src_url_and_transformtaion", unique: true

end

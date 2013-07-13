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

ActiveRecord::Schema.define(version: 20130713022209) do

  create_table "bitcoin_invoices", force: true do |t|
    t.decimal  "price"
    t.string   "currency",           limit: 3,  default: "USD"
    t.string   "pos_data"
    t.string   "notification_url"
    t.string   "invoice_id"
    t.string   "invoice_url"
    t.string   "buyer_name"
    t.boolean  "physical"
    t.string   "description"
    t.string   "transaction_speed"
    t.boolean  "full_notifications"
    t.decimal  "btc_price"
    t.datetime "invoice_time"
    t.datetime "expiration_time"
    t.string   "status",             limit: 16, default: "new"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notification_key"
  end

  add_index "bitcoin_invoices", ["notification_key"], name: "index_bitcoin_invoices_on_notification_key", unique: true

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
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

end

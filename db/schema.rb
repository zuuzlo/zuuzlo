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

ActiveRecord::Schema.define(version: 20140304020240) do

  create_table "categories", force: true do |t|
    t.string   "name"
    t.integer  "ls_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "categories", ["slug"], name: "index_categories_on_slug", using: :btree

  create_table "categories_coupons", force: true do |t|
    t.integer "category_id"
    t.integer "coupon_id"
  end

  add_index "categories_coupons", ["category_id"], name: "index_categories_coupons_on_category_id", using: :btree
  add_index "categories_coupons", ["coupon_id"], name: "index_categories_coupons_on_coupon_id", using: :btree

  create_table "coupons", force: true do |t|
    t.string   "id_of_coupon"
    t.text     "title"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "code"
    t.text     "restriction"
    t.text     "link"
    t.text     "impression_pixel"
    t.text     "image"
    t.integer  "store_id"
    t.integer  "coupon_source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coupons", ["coupon_source_id"], name: "index_coupons_on_coupon_source_id", using: :btree
  add_index "coupons", ["store_id"], name: "index_coupons_on_store_id", using: :btree

  create_table "coupons_ctypes", force: true do |t|
    t.integer "coupon_id"
    t.integer "ctype_id"
  end

  add_index "coupons_ctypes", ["coupon_id"], name: "index_coupons_ctypes_on_coupon_id", using: :btree
  add_index "coupons_ctypes", ["ctype_id"], name: "index_coupons_ctypes_on_ctype_id", using: :btree

  create_table "ctypes", force: true do |t|
    t.string   "name"
    t.integer  "ls_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "ctypes", ["slug"], name: "index_ctypes_on_slug", using: :btree

  create_table "stores", force: true do |t|
    t.string   "name"
    t.integer  "id_of_store"
    t.text     "description"
    t.text     "home_page_url"
    t.boolean  "active_commission"
    t.string   "store_img"
    t.float    "commission"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "stores", ["slug"], name: "index_stores_on_slug", unique: true, using: :btree

end

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

ActiveRecord::Schema.define(:version => 20120806030312) do

  create_table "areas", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "seller_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "active",         :default => true
    t.boolean  "is_1568",        :default => false
    t.string   "pinyin"
    t.integer  "children_count", :default => 0
    t.integer  "lft",            :default => 0
    t.integer  "rgt",            :default => 0
    t.integer  "sellers_count",  :default => 0
    t.integer  "area_type"
    t.string   "zip"
  end

  create_table "colors", :force => true do |t|
    t.string   "hexcode"
    t.string   "name"
    t.string   "num"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "colors", ["num"], :name => "index_colors_on_num"

  create_table "sellers", :force => true do |t|
    t.string   "name"
    t.string   "fullname"
    t.string   "address"
    t.string   "mobile"
    t.string   "phone"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "children_count", :default => 0
    t.string   "email"
    t.string   "telephone"
    t.string   "cc_emails"
    t.integer  "user_id"
    t.string   "pinyin"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.integer  "role_level",                          :default => 10
    t.integer  "sellers_count",                       :default => 0
    t.integer  "parent_id"
    t.integer  "children_count",                      :default => 0
    t.integer  "lft",                                 :default => 0
    t.integer  "rgt",                                 :default => 0
    t.string   "name"
  end

  add_index "users", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "users", ["parent_id"], :name => "index_admins_on_parent_id"
  add_index "users", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

end

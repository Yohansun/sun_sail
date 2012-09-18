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

ActiveRecord::Schema.define(:version => 20120918062804) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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

  create_table "products", :force => true do |t|
    t.string  "name",           :limit => 100,                               :default => "",  :null => false
    t.string  "iid",            :limit => 20,                                :default => "",  :null => false
    t.string  "taobao_id",      :limit => 20,                                :default => "",  :null => false
    t.string  "storage_num",    :limit => 20,                                :default => "",  :null => false
    t.decimal "price",                         :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.string  "status"
    t.string  "quantity"
    t.string  "category"
    t.string  "features"
    t.text    "technical_data"
    t.text    "description"
    t.string  "level"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "sellers", :force => true do |t|
    t.string   "name"
    t.string   "fullname"
    t.string   "address"
    t.string   "mobile"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "children_count",    :default => 0
    t.string   "email"
    t.string   "telephone"
    t.string   "cc_emails"
    t.integer  "user_id"
    t.string   "pinyin"
    t.boolean  "active",            :default => true
    t.string   "interface"
    t.integer  "performance_score", :default => 0
    t.boolean  "has_stock"
  end

  create_table "stock_histories", :force => true do |t|
    t.string   "operation"
    t.integer  "number"
    t.integer  "stock_product_id"
    t.string   "tid"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "reason"
    t.string   "note"
    t.integer  "seller_id"
  end

  add_index "stock_histories", ["seller_id"], :name => "index_stock_histories_on_seller_id"

  create_table "stock_products", :force => true do |t|
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "max",        :default => 0
    t.integer  "safe_value", :default => 0
    t.integer  "activity",   :default => 0
    t.integer  "actual",     :default => 0
    t.integer  "product_id"
    t.integer  "seller_id"
  end

  add_index "stock_products", ["seller_id"], :name => "index_stock_products_on_seller_id"

  create_table "trade_sources", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.string   "app_key"
    t.string   "secret_key"
    t.string   "session"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "trade_type"
    t.integer  "fetch_quantity",      :default => 20
    t.integer  "fetch_time_circle",   :default => 15
    t.boolean  "high_pressure_valve", :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "username",                                              :null => false
    t.string   "name"
    t.string   "email",                               :default => "",   :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",   :null => false
    t.string   "password_salt",                       :default => "",   :null => false
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
    t.boolean  "active",                              :default => true
    t.integer  "seller_id"
  end

  add_index "users", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "users", ["parent_id"], :name => "index_admins_on_parent_id"
  add_index "users", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "users_bak", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "is_super_admin",         :default => false
    t.string   "name"
  end

  add_index "users_bak", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users_bak", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end

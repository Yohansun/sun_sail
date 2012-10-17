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

ActiveRecord::Schema.define(:version => 20121017121858) do

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

  add_index "areas", ["name"], :name => "index_areas_on_name"
  add_index "areas", ["parent_id"], :name => "index_areas_on_parent_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "colors", :force => true do |t|
    t.string   "hexcode"
    t.string   "name"
    t.string   "num"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "colors", ["num"], :name => "index_colors_on_num"

  create_table "colors_products", :force => true do |t|
    t.integer  "color_id"
    t.integer  "product_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "colors_products", ["product_id"], :name => "index_colors_products_on_product_id"

  create_table "colors_stock_products", :force => true do |t|
    t.integer "color_id"
    t.integer "stock_product_id"
  end

  add_index "colors_stock_products", ["stock_product_id"], :name => "index_colors_stock_products_on_stock_product_id"

  create_table "feature_product_relationships", :force => true do |t|
    t.integer  "product_id"
    t.integer  "feature_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "features", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "grades", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "logistic_areas", :force => true do |t|
    t.integer  "logistic_id"
    t.integer  "area_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "logistic_areas", ["area_id"], :name => "index_logistic_areas_on_area_id"
  add_index "logistic_areas", ["logistic_id"], :name => "index_logistic_areas_on_logistic_id"

  create_table "logistics", :force => true do |t|
    t.string   "name"
    t.string   "options"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "code"
  end

  create_table "products", :force => true do |t|
    t.string  "name",           :limit => 100,                               :default => "",  :null => false
    t.string  "iid",            :limit => 20,                                :default => "",  :null => false
    t.string  "taobao_id",      :limit => 20,                                :default => "",  :null => false
    t.string  "storage_num",    :limit => 20,                                :default => "",  :null => false
    t.decimal "price",                         :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.string  "status"
    t.integer "quantity_id"
    t.integer "category_id"
    t.string  "features"
    t.text    "technical_data"
    t.text    "description"
    t.integer "grade_id"
    t.string  "product_image"
    t.integer "parent_id"
    t.integer "lft",                                                         :default => 0
    t.integer "rgt",                                                         :default => 0
    t.integer "good_type"
  end

  create_table "quantities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
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
    t.integer  "performance_score", :default => 0
    t.string   "interface"
    t.boolean  "has_stock",         :default => false
    t.datetime "stock_opened_at"
  end

  create_table "sellers_areas", :force => true do |t|
    t.integer  "seller_id"
    t.integer  "area_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sellers_areas", ["area_id"], :name => "index_sellers_areas_on_area_id"
  add_index "sellers_areas", ["seller_id"], :name => "index_sellers_areas_on_seller_id"

  create_table "settings", :force => true do |t|
    t.string   "var",                      :null => false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", :limit => 30
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "settings", ["thing_type", "thing_id", "var"], :name => "index_settings_on_thing_type_and_thing_id_and_var", :unique => true

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

  create_table "stocks", :force => true do |t|
    t.string   "name"
    t.integer  "seller_id"
    t.integer  "product_count",    :default => 0
    t.integer  "stock_product_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "taobao_app_tokens", :force => true do |t|
    t.integer  "account_id"
    t.string   "access_token"
    t.string   "taobao_user_id"
    t.string   "taobao_user_nick"
    t.string   "refresh_token"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.datetime "last_refresh_at"
    t.integer  "trade_source_id"
    t.datetime "refresh_token_last_refresh_at"
  end

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
    t.integer  "logistic_id"
    t.integer  "failed_attempts"
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "users", ["parent_id"], :name => "index_admins_on_parent_id"
  add_index "users", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end

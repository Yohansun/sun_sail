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

ActiveRecord::Schema.define(:version => 20130916092012) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "key"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "seller_name"
    t.string   "address"
    t.string   "phone"
    t.string   "deliver_bill_info"
    t.string   "point_out"
    t.string   "website"
  end

  create_table "accounts_users", :force => true do |t|
    t.integer "account_id"
    t.integer "user_id"
  end

  create_table "alipay_trade_histories", :force => true do |t|
    t.string   "finance_trade_sn"
    t.string   "business_trade_sn"
    t.string   "merchant_trade_sn"
    t.string   "product_name"
    t.datetime "traded_at"
    t.string   "account_info"
    t.decimal  "revenue_amount",                   :precision => 10, :scale => 0
    t.decimal  "outlay_amount",                    :precision => 10, :scale => 0
    t.decimal  "balance_amount",                   :precision => 10, :scale => 0
    t.string   "trade_source"
    t.string   "trade_type"
    t.string   "memo",              :limit => 500
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
  end

  add_index "alipay_trade_histories", ["trade_type"], :name => "index_alipay_trade_histories_on_trade_type"

  create_table "alipay_trade_orders", :force => true do |t|
    t.integer  "reconcile_statement_id"
    t.integer  "alipay_trade_history_id"
    t.string   "original_trade_sn"
    t.string   "trade_sn"
    t.datetime "traded_at"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "alipay_trade_orders", ["alipay_trade_history_id"], :name => "index_alipay_trade_orders_on_alipay_trade_history_id"
  add_index "alipay_trade_orders", ["original_trade_sn"], :name => "index_alipay_trade_orders_on_original_trade_sn"
  add_index "alipay_trade_orders", ["reconcile_statement_id"], :name => "index_alipay_trade_orders_on_reconcile_statement_id"
  add_index "alipay_trade_orders", ["trade_sn"], :name => "index_alipay_trade_orders_on_trade_sn"

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

  create_table "bbs_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "account_id"
  end

  create_table "bbs_topics", :force => true do |t|
    t.integer  "bbs_category_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.integer  "read_count",      :default => 0
    t.integer  "download_count",  :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "account_id"
  end

  add_index "bbs_topics", ["bbs_category_id"], :name => "index_bbs_topics_on_bbs_category_id"
  add_index "bbs_topics", ["user_id"], :name => "index_bbs_topics_on_user_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
    t.integer  "account_id"
    t.integer  "status",     :default => 1
    t.integer  "use_days",   :default => 0, :null => false
  end

  add_index "categories", ["status"], :name => "index_categories_on_status"

  create_table "categories_category_properties", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "category_property_id"
  end

  add_index "categories_category_properties", ["category_id"], :name => "index_categories_category_properties_on_category_id"
  add_index "categories_category_properties", ["category_property_id"], :name => "index_categories_category_properties_on_category_property_id"

  create_table "category_properties", :force => true do |t|
    t.string   "name"
    t.integer  "value_type"
    t.integer  "taobao_id"
    t.integer  "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "category_properties", ["name"], :name => "index_category_properties_on_name"
  add_index "category_properties", ["status"], :name => "index_category_properties_on_status"

  create_table "category_property_values", :force => true do |t|
    t.integer  "category_property_id"
    t.string   "value"
    t.integer  "taobao_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "category_property_values", ["category_property_id"], :name => "index_category_property_values_on_category_property_id"
  add_index "category_property_values", ["taobao_id"], :name => "index_category_property_values_on_taobao_id"
  add_index "category_property_values", ["value"], :name => "index_category_property_values_on_value"

  create_table "colors", :force => true do |t|
    t.string   "hexcode"
    t.string   "name"
    t.string   "num"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "account_id"
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

  create_table "deliver_templates", :force => true do |t|
    t.string   "name"
    t.string   "xml"
    t.string   "image"
    t.string   "account_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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
    t.integer  "account_id"
  end

  create_table "logistic_areas", :force => true do |t|
    t.integer  "logistic_id"
    t.integer  "area_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "account_id"
  end

  add_index "logistic_areas", ["area_id"], :name => "index_logistic_areas_on_area_id"
  add_index "logistic_areas", ["logistic_id"], :name => "index_logistic_areas_on_logistic_id"

  create_table "logistic_groups", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.integer  "split_number"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "logistic_groups", ["account_id"], :name => "index_logistic_groups_on_account_id"

  create_table "logistic_rates", :force => true do |t|
    t.integer  "seller_id"
    t.integer  "logistic_id"
    t.integer  "score"
    t.string   "mobile"
    t.string   "tid"
    t.datetime "send_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "taobao_rate_score"
    t.integer  "account_id"
  end

  create_table "logistics", :force => true do |t|
    t.string   "name"
    t.string   "options"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "code",       :default => "OTHER"
    t.string   "xml"
    t.integer  "account_id"
  end

  create_table "onsite_service_areas", :force => true do |t|
    t.string   "account_id"
    t.integer  "area_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "packages", :force => true do |t|
    t.string   "outer_id"
    t.integer  "number",     :default => 1
    t.integer  "product_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "packages", ["outer_id"], :name => "index_packages_on_iid"
  add_index "packages", ["product_id"], :name => "index_packages_on_product_id"

  create_table "print_flash_settings", :force => true do |t|
    t.text     "xml_hash"
    t.integer  "account_id"
    t.integer  "logistic_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "products", :force => true do |t|
    t.string   "name",              :limit => 100,                               :default => "",   :null => false
    t.string   "outer_id",          :limit => 20,                                :default => "",   :null => false
    t.string   "product_id",        :limit => 20,                                :default => "",   :null => false
    t.string   "storage_num",       :limit => 20,                                :default => "",   :null => false
    t.decimal  "price",                            :precision => 8, :scale => 2, :default => 0.0,  :null => false
    t.integer  "quantity_id"
    t.integer  "category_id"
    t.string   "features"
    t.string   "product_image"
    t.integer  "parent_id"
    t.integer  "lft",                                                            :default => 0
    t.integer  "rgt",                                                            :default => 0
    t.integer  "good_type"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.string   "cat_name"
    t.string   "pic_url"
    t.string   "detail_url"
    t.string   "cid"
    t.integer  "num_iid",           :limit => 8
    t.integer  "account_id"
    t.integer  "logistic_group_id"
    t.boolean  "on_sale",                                                        :default => true
  end

  create_table "quantities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "account_id"
  end

  create_table "reconcile_statement_details", :force => true do |t|
    t.integer  "reconcile_statement_id"
    t.integer  "alipay_revenue",         :default => 0
    t.integer  "postfee_revenue",        :default => 0
    t.integer  "trade_success_refund",   :default => 0
    t.integer  "sell_refund",            :default => 0
    t.integer  "base_service_fee",       :default => 0
    t.integer  "store_service_award",    :default => 0
    t.integer  "staff_award",            :default => 0
    t.integer  "taobao_cost",            :default => 0
    t.integer  "audit_cost",             :default => 0
    t.integer  "collecting_postfee",     :default => 0
    t.integer  "audit_amount",           :default => 0
    t.integer  "adjust_amount",          :default => 0
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "reconcile_statement_details", ["reconcile_statement_id"], :name => "index_reconcile_statement_details_on_reconcile_statement_id"

  create_table "reconcile_statements", :force => true do |t|
    t.string   "trade_store_source"
    t.string   "trade_store_name"
    t.integer  "balance_amount"
    t.boolean  "audited",            :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.datetime "audit_time"
    t.text     "exported"
    t.integer  "account_id"
  end

  add_index "reconcile_statements", ["created_at"], :name => "index_reconcile_statements_on_created_at"
  add_index "reconcile_statements", ["trade_store_source"], :name => "index_reconcile_statements_on_trade_store_source"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "byname"
    t.text     "permissions"
    t.integer  "account_id",       :null => false
    t.boolean  "can_assign_trade"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "sales", :force => true do |t|
    t.string   "name"
    t.float    "earn_guess"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "account_id"
  end

  create_table "sellers", :force => true do |t|
    t.string   "name"
    t.string   "fullname"
    t.string   "address"
    t.string   "mobile"
    t.string   "phone"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "children_count",    :default => 0
    t.text     "email"
    t.string   "telephone"
    t.text     "cc_emails"
    t.integer  "user_id"
    t.string   "pinyin"
    t.boolean  "active",            :default => true
    t.integer  "performance_score", :default => 0
    t.string   "interface"
    t.boolean  "has_stock",         :default => false
    t.datetime "stock_opened_at"
    t.integer  "account_id"
    t.string   "stock_name"
    t.integer  "stock_user_id"
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

  create_table "sku_bindings", :force => true do |t|
    t.integer "sku_id",        :limit => 8
    t.integer "taobao_sku_id", :limit => 8
    t.integer "number",        :limit => 8
  end

  create_table "sku_properties", :force => true do |t|
    t.integer  "sku_id"
    t.integer  "category_property_value_id"
    t.string   "cached_property_name"
    t.string   "cached_property_value"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "category_property_id"
  end

  add_index "sku_properties", ["category_property_id"], :name => "index_sku_properties_on_category_property_id"
  add_index "sku_properties", ["category_property_value_id"], :name => "index_sku_properties_on_category_property_value_id"
  add_index "sku_properties", ["sku_id"], :name => "index_sku_properties_on_sku_id"

  create_table "skus", :force => true do |t|
    t.string  "sku_id"
    t.integer "num_iid",         :limit => 8
    t.string  "properties",                   :default => ""
    t.string  "properties_name",              :default => ""
    t.integer "quantity"
    t.integer "product_id"
    t.integer "account_id"
    t.string  "code"
  end

  create_table "stock_csv_files", :force => true do |t|
    t.string   "path"
    t.integer  "upload_user_id"
    t.string   "stock_in_bill_id"
    t.boolean  "used"
    t.integer  "seller_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
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
    t.integer  "account_id"
  end

  add_index "stock_histories", ["seller_id"], :name => "index_stock_histories_on_seller_id"

  create_table "stock_products", :force => true do |t|
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "max",                     :default => 0
    t.integer  "safe_value",              :default => 0
    t.integer  "activity",                :default => 0
    t.integer  "actual",                  :default => 0
    t.integer  "product_id"
    t.integer  "seller_id"
    t.integer  "sku_id",     :limit => 8
    t.integer  "num_iid",    :limit => 8
    t.integer  "account_id"
  end

  add_index "stock_products", ["seller_id"], :name => "index_stock_products_on_seller_id"

  create_table "stocks", :force => true do |t|
    t.string   "name"
    t.integer  "seller_id"
    t.integer  "product_count",    :default => 0
    t.integer  "stock_product_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "account_id"
  end

  create_table "taobao_app_tokens", :force => true do |t|
    t.integer  "account_id"
    t.string   "access_token"
    t.string   "taobao_user_id"
    t.string   "taobao_user_nick"
    t.string   "refresh_token"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.datetime "last_refresh_at"
    t.integer  "trade_source_id"
    t.datetime "refresh_token_last_refresh_at"
    t.integer  "re_expires_in",                 :limit => 8
    t.integer  "r1_expires_in",                 :limit => 8
    t.integer  "r2_expires_in",                 :limit => 8
    t.integer  "w1_expires_in",                 :limit => 8
    t.integer  "w2_expires_in",                 :limit => 8
    t.boolean  "need_refresh",                               :default => true
  end

  create_table "taobao_products", :force => true do |t|
    t.integer  "category_id"
    t.integer  "account_id"
    t.integer  "num_iid",     :limit => 8
    t.decimal  "price",                    :precision => 10, :scale => 0
    t.string   "outer_id"
    t.string   "product_id"
    t.string   "cat_name"
    t.string   "pic_url"
    t.string   "cid"
    t.string   "name"
    t.datetime "updated_at"
  end

  create_table "taobao_skus", :force => true do |t|
    t.integer "sku_id",            :limit => 8
    t.integer "taobao_product_id", :limit => 8
    t.integer "num_iid",           :limit => 8
    t.string  "properties",                     :default => ""
    t.string  "properties_name",                :default => ""
    t.integer "quantity"
    t.integer "account_id"
  end

  create_table "taobao_trade_rates", :force => true do |t|
    t.string   "tid"
    t.string   "oid"
    t.string   "role"
    t.string   "nick"
    t.text     "result"
    t.datetime "created"
    t.string   "rated_nick"
    t.string   "item_title"
    t.float    "item_price"
    t.string   "content"
    t.string   "reply"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "taobao_trade_rates", ["oid"], :name => "index_taobao_trade_rates_on_oid"
  add_index "taobao_trade_rates", ["tid"], :name => "index_taobao_trade_rates_on_tid"

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
    t.integer  "sid"
    t.integer  "cid"
    t.datetime "created"
    t.datetime "modified"
    t.string   "bulletin"
    t.string   "title"
    t.string   "description"
  end

  create_table "upload_files", :force => true do |t|
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  create_table "users", :force => true do |t|
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
    t.boolean  "active",                 :default => true
    t.integer  "seller_id"
    t.string   "username"
    t.integer  "logistic_id"
    t.integer  "failed_attempts"
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "phone"
    t.boolean  "superadmin",             :default => false, :null => false
    t.boolean  "can_assign_trade"
    t.integer  "trade_percent"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end

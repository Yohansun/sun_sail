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

ActiveRecord::Schema.define(:version => 20140303090851) do

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

  add_index "accounts_users", ["user_id", "account_id"], :name => "index_accounts_users_on_account_id_and_user_id"

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

  add_index "areas", ["lft"], :name => "index_areas_on_lft"
  add_index "areas", ["name", "parent_id"], :name => "index_sellers_areas_on_name_and_parent_id"
  add_index "areas", ["name"], :name => "index_areas_on_name"
  add_index "areas", ["parent_id"], :name => "index_areas_on_parent_id"
  add_index "areas", ["rgt"], :name => "index_areas_on_rgt"
  add_index "areas", ["seller_id"], :name => "index_areas_on_seller_id"

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

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

  add_index "categories", ["account_id"], :name => "index_categories_on_account_id"
  add_index "categories", ["lft"], :name => "index_categories_on_lgt"
  add_index "categories", ["rgt"], :name => "index_categories_on_rgt"
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
    t.integer  "account_id"
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

  create_table "distributors", :force => true do |t|
    t.integer  "trade_source_id"
    t.string   "name"
    t.string   "trade_type",      :default => "Taobao"
    t.string   "string",          :default => "Taobao"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
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

  create_table "jingdong_app_tokens", :force => true do |t|
    t.integer  "account_id"
    t.string   "access_token"
    t.string   "refresh_token"
    t.string   "jingdong_user_id"
    t.string   "jingdong_user_nick"
    t.integer  "trade_source_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "jingdong_products", :force => true do |t|
    t.integer  "ware_id",              :limit => 8,                                :null => false
    t.string   "spu_id"
    t.integer  "cid"
    t.integer  "vender_id"
    t.integer  "shop_id"
    t.string   "ware_status"
    t.string   "title"
    t.string   "item_num"
    t.string   "upc_code"
    t.integer  "transport_id"
    t.string   "online_time"
    t.string   "offline_time"
    t.text     "attribute_s"
    t.text     "desc"
    t.string   "producter"
    t.string   "wrap"
    t.string   "cubage"
    t.string   "pack_listing"
    t.string   "service"
    t.decimal  "cost_price",                        :precision => 10, :scale => 0
    t.decimal  "market_price",                      :precision => 10, :scale => 0
    t.decimal  "jd_price",                          :precision => 10, :scale => 0
    t.integer  "stock_num"
    t.string   "logo"
    t.string   "creator"
    t.string   "status"
    t.integer  "weight"
    t.datetime "created"
    t.datetime "modified"
    t.string   "outer_id"
    t.string   "shop_categorys"
    t.boolean  "is_pay_first"
    t.boolean  "is_can_vat"
    t.boolean  "is_imported"
    t.boolean  "is_health_product"
    t.boolean  "is_shelf_life"
    t.integer  "shelf_life_days"
    t.boolean  "is_serial_no"
    t.boolean  "is_appliances_card"
    t.boolean  "is_special_wet"
    t.integer  "ware_big_small_model"
    t.integer  "ware_pack_type"
    t.integer  "account_id"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "trade_source_id"
    t.string   "shop_name"
  end

  add_index "jingdong_products", ["ware_id"], :name => "index_jingdong_products_on_ware_id", :unique => true

  create_table "jingdong_skus", :force => true do |t|
    t.integer  "sku_id",                                         :null => false
    t.integer  "shop_id"
    t.integer  "ware_id"
    t.string   "status"
    t.string   "attribute_s"
    t.integer  "stock_num"
    t.decimal  "jd_price",        :precision => 10, :scale => 0
    t.decimal  "cost_price",      :precision => 10, :scale => 0
    t.decimal  "market_price",    :precision => 10, :scale => 0
    t.string   "outer_id"
    t.datetime "created"
    t.datetime "modified"
    t.string   "color_value"
    t.string   "size_value"
    t.integer  "account_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.integer  "trade_source_id"
    t.string   "shop_name"
  end

  add_index "jingdong_skus", ["status"], :name => "index_jingdong_skus_on_status"
  add_index "jingdong_skus", ["ware_id", "sku_id"], :name => "index_jingdong_skus_on_ware_id_and_sku_id", :unique => true

  create_table "logistic_areas", :force => true do |t|
    t.integer  "logistic_id"
    t.integer  "area_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "account_id"
    t.float    "basic_post_weight"
    t.float    "extra_post_weight"
    t.float    "basic_post_fee"
    t.float    "extra_post_fee"
  end

  add_index "logistic_areas", ["account_id"], :name => "index_logistic_areas_on_account_id"
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
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "code",              :default => "OTHER"
    t.string   "print_image"
    t.integer  "account_id"
    t.float    "basic_post_weight", :default => 0.0
    t.float    "extra_post_weight", :default => 0.0
    t.float    "basic_post_fee",    :default => 0.0
    t.float    "extra_post_fee",    :default => 0.0
  end

  add_index "logistics", ["account_id"], :name => "index_logistics_on_account_id"

  create_table "onsite_service_areas", :force => true do |t|
    t.string   "account_id"
    t.integer  "area_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "onsite_service_areas", ["area_id", "account_id"], :name => "index_onsite_service_areas_on_account_id_and_area_id"

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
    t.text     "xml_hash",    :limit => 16777215
    t.integer  "account_id"
    t.integer  "logistic_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "products", :force => true do |t|
    t.string   "name",              :limit => 100,                               :default => "",   :null => false
    t.string   "outer_id",          :limit => 20,                                :default => ""
    t.string   "product_id",        :limit => 20,                                :default => ""
    t.string   "storage_num",       :limit => 20,                                :default => ""
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

  add_index "products", ["account_id"], :name => "index_products_on_account_id"
  add_index "products", ["category_id"], :name => "index_products_on_category_id"
  add_index "products", ["num_iid"], :name => "index_products_on_num_iid"
  add_index "products", ["outer_id"], :name => "index_products_on_outer_id"
  add_index "products", ["storage_num"], :name => "index_products_on_storage_num"

  create_table "quantities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "account_id"
  end

  create_table "reconcile_product_details", :force => true do |t|
    t.string   "name"
    t.string   "outer_id"
    t.integer  "reconcile_statement_id"
    t.integer  "initial_num"
    t.integer  "subtraction"
    t.integer  "total_num"
    t.float    "last_month_num"
    t.integer  "product_id"
    t.integer  "offline_return"
    t.integer  "hidden_num"
    t.integer  "seller_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "audit_num",              :default => 0
    t.integer  "audit_price",            :default => 0
  end

  add_index "reconcile_product_details", ["outer_id"], :name => "index_reconcile_product_details_on_outer_id"

  create_table "reconcile_seller_details", :force => true do |t|
    t.integer  "reconcile_statement_id"
    t.string   "source"
    t.integer  "trade_source_name"
    t.integer  "alipay_revenue",                       :default => 0
    t.integer  "postfee_revenue",                      :default => 0
    t.integer  "base_fee",                             :default => 0
    t.integer  "base_fee_rate",                        :default => 2
    t.integer  "audit_amount",                         :default => 0
    t.integer  "special_products_alipay_revenue",      :default => 0
    t.integer  "special_products_alipay_revenue_rate", :default => 2
    t.integer  "audit_amount_rate",                    :default => 2
    t.integer  "adjust_amount",                        :default => 0
    t.integer  "last_audit_amount",                    :default => 0
    t.integer  "user_id"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.integer  "buyer_payment",                        :default => 0
    t.integer  "preferential",                         :default => 0
    t.integer  "buyer_send_postage",                   :default => 0
    t.integer  "taobao_deduction",                     :default => 0
    t.integer  "credit_deduction",                     :default => 0
    t.integer  "rebate_integral",                      :default => 0
    t.integer  "actual_pey",                           :default => 0
  end

  create_table "reconcile_statement_details", :force => true do |t|
    t.integer  "reconcile_statement_id"
    t.integer  "alipay_revenue",                                       :default => 0
    t.integer  "postfee_revenue",                                      :default => 0
    t.integer  "trade_success_refund",                                 :default => 0
    t.integer  "sell_refund",                                          :default => 0
    t.integer  "base_service_fee",                                     :default => 0
    t.integer  "store_service_award",                                  :default => 0
    t.integer  "staff_award",                                          :default => 0
    t.integer  "taobao_cost",                                          :default => 0
    t.integer  "audit_cost",                                           :default => 0
    t.integer  "collecting_postfee",                                   :default => 0
    t.integer  "audit_amount",                                         :default => 0
    t.integer  "adjust_amount",                                        :default => 0
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.integer  "special_products_alipay_revenue",                      :default => 0
    t.integer  "special_products_audit_amount",                        :default => 0
    t.integer  "base_fee",                                             :default => 0
    t.integer  "last_audit_amount",                                    :default => 0
    t.integer  "account_profit",                                       :default => 0
    t.integer  "advertise_reserved",                                   :default => 0
    t.integer  "platform_deduction",                                   :default => 0
    t.integer  "base_fee_percent",                                     :default => 5
    t.integer  "special_products_audit_amount_percent",                :default => 5
    t.integer  "audit_amount_percent",                                 :default => 5
    t.integer  "account_profit_percent_a",                             :default => 5
    t.integer  "account_profit_percent_b",                             :default => 5
    t.integer  "account_profit_percent_c",                             :default => 5
    t.integer  "advertise_reserved_percent_a",                         :default => 5
    t.integer  "advertise_reserved_percent_b",                         :default => 5
    t.integer  "platform_deduction_percent_a",                         :default => 5
    t.integer  "platform_deduction_percent_b",                         :default => 5
    t.integer  "user_id"
    t.integer  "achievement",                                          :default => 0
    t.integer  "credit_card_money",                                    :default => 0
    t.integer  "sale_commission",                                      :default => 0
    t.integer  "return_point_money",                                   :default => 0
    t.integer  "other_point_money",                                    :default => 0
    t.integer  "handmade_trade_money",                                 :default => 0
    t.string   "memo",                                  :limit => 500
  end

  add_index "reconcile_statement_details", ["reconcile_statement_id"], :name => "index_reconcile_statement_details_on_reconcile_statement_id"

  create_table "reconcile_statements", :force => true do |t|
    t.string   "trade_store_source"
    t.string   "trade_store_name"
    t.float    "balance_amount",     :default => 0.0
    t.boolean  "audited",            :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.datetime "audit_time"
    t.text     "exported"
    t.integer  "account_id"
    t.integer  "seller_id"
    t.boolean  "processed",          :default => false
    t.string   "trade_source_id"
  end

  add_index "reconcile_statements", ["created_at"], :name => "index_reconcile_statements_on_created_at"
  add_index "reconcile_statements", ["trade_store_source"], :name => "index_reconcile_statements_on_trade_store_source"

  create_table "refund_orders", :force => true do |t|
    t.integer  "refund_product_id"
    t.string   "title"
    t.string   "num_iid"
    t.decimal  "refund_price",      :precision => 10, :scale => 0, :default => 0
    t.integer  "num",                                              :default => 0, :null => false
    t.integer  "sku_id"
    t.string   "outer_id"
    t.integer  "stock_product_id"
    t.integer  "account_id"
    t.string   "order_type"
    t.integer  "seller_id"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
  end

  create_table "refund_products", :force => true do |t|
    t.integer  "refund_id",         :limit => 8
    t.string   "buyer_name"
    t.string   "mobile"
    t.string   "phone"
    t.string   "zip"
    t.string   "status"
    t.datetime "refund_time"
    t.string   "tid"
    t.integer  "state_id"
    t.integer  "city_id"
    t.integer  "district_id"
    t.string   "address"
    t.text     "reason"
    t.decimal  "total_price",                    :precision => 10, :scale => 0, :default => 0,    :null => false
    t.decimal  "refund_fee",                     :precision => 10, :scale => 0, :default => 0,    :null => false
    t.integer  "account_id"
    t.string   "ec_name"
    t.boolean  "is_location",                                                   :default => true, :null => false
    t.integer  "seller_id"
    t.text     "status_operations"
    t.datetime "created_at",                                                                      :null => false
    t.datetime "updated_at",                                                                      :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
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
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
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
    t.string   "trade_type",        :default => "Taobao"
  end

  add_index "sellers", ["account_id"], :name => "index_areas_on_account_id"
  add_index "sellers", ["active"], :name => "index_sellers_on_active"
  add_index "sellers", ["lft"], :name => "index_sellers_on_lft"
  add_index "sellers", ["performance_score"], :name => "index_sellers_on_performance_score"
  add_index "sellers", ["rgt"], :name => "index_sellers_on_rgt"

  create_table "sellers_areas", :force => true do |t|
    t.integer  "seller_id"
    t.integer  "area_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sellers_areas", ["area_id", "seller_id"], :name => "index_sellers_areas_on_area_id_and_seller_id"
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
    t.integer "number",        :limit => 8
    t.integer "resource_id"
    t.string  "resource_type"
  end

  add_index "sku_bindings", ["sku_id"], :name => "index_stock_sku_bindings_on_sku_id_and_taobao_sku_id"

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

  add_index "skus", ["account_id"], :name => "index_skus_on_account_id"
  add_index "skus", ["num_iid"], :name => "index_skus_on_num_iid"
  add_index "skus", ["product_id", "account_id"], :name => "index_skus_on_account_id_and_product_id"
  add_index "skus", ["product_id"], :name => "index_skus_on_product_id"
  add_index "skus", ["sku_id"], :name => "index_skus_on_sku_id"

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

  add_index "stock_products", ["seller_id", "account_id"], :name => "index_stock_products_on_account_id_and_seller_id"
  add_index "stock_products", ["seller_id"], :name => "index_stock_products_on_seller_id"
  add_index "stock_products", ["sku_id", "product_id"], :name => "index_stock_products_on_sku_id_and_product_id"

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

  add_index "taobao_app_tokens", ["account_id"], :name => "index_taobao_app_tokens_on_account_id"
  add_index "taobao_app_tokens", ["trade_source_id"], :name => "index_taobao_app_tokens_on_trade_source_id"

  create_table "taobao_products", :force => true do |t|
    t.integer  "category_id"
    t.integer  "account_id"
    t.integer  "num_iid",         :limit => 8
    t.decimal  "price",                        :precision => 10, :scale => 0
    t.string   "outer_id"
    t.string   "product_id"
    t.string   "cat_name"
    t.string   "pic_url"
    t.string   "cid"
    t.string   "name"
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.integer  "trade_source_id"
    t.string   "shop_name"
  end

  add_index "taobao_products", ["account_id"], :name => "index_taobao_products_on_account_id"
  add_index "taobao_products", ["category_id"], :name => "index_taobao_products_on_category_id"
  add_index "taobao_products", ["outer_id"], :name => "index_taobao_products_on_outer_id"

  create_table "taobao_skus", :force => true do |t|
    t.integer  "sku_id",            :limit => 8
    t.integer  "taobao_product_id", :limit => 8
    t.integer  "num_iid",           :limit => 8
    t.string   "properties"
    t.string   "properties_name"
    t.integer  "quantity"
    t.integer  "account_id"
    t.integer  "trade_source_id"
    t.string   "shop_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "property_alias"
  end

  add_index "taobao_skus", ["account_id"], :name => "index_taobao_skus_on_account_id"
  add_index "taobao_skus", ["num_iid"], :name => "index_taobao_skus_on_num_iid"
  add_index "taobao_skus", ["sku_id"], :name => "index_taobao_skus_on_sku_id"
  add_index "taobao_skus", ["taobao_product_id"], :name => "index_taobao_skus_on_taobao_product_id"

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

  create_table "third_parties", :force => true do |t|
    t.integer  "user_id"
    t.integer  "account_id"
    t.string   "name"
    t.string   "authentication_token"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.boolean  "is_default",           :default => false
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
    t.integer  "sid"
    t.integer  "cid"
    t.datetime "created"
    t.datetime "modified"
    t.string   "bulletin"
    t.string   "title"
    t.string   "description"
    t.boolean  "jushita_sync",        :default => false, :null => false
    t.integer  "enabled_checker"
  end

  add_index "trade_sources", ["account_id"], :name => "index_trade_sources_on_account_id"

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

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "yihaodian_app_tokens", :force => true do |t|
    t.integer  "account_id"
    t.string   "access_token"
    t.string   "refresh_token"
    t.integer  "yihaodian_user_id"
    t.string   "yihaodian_user_nick"
    t.integer  "trade_source_id"
    t.integer  "isv_id"
    t.integer  "merchant_id"
    t.string   "user_code"
    t.integer  "user_type"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "yihaodian_products", :force => true do |t|
    t.string   "product_code",                      :null => false
    t.string   "product_cname",                     :null => false
    t.integer  "product_id",           :limit => 8
    t.string   "ean13"
    t.integer  "category_id",          :limit => 8
    t.integer  "can_sale"
    t.string   "outer_id"
    t.integer  "can_show"
    t.integer  "verify_flg"
    t.integer  "is_dup_audit"
    t.text     "prod_img"
    t.string   "prod_detail_url"
    t.integer  "brand_id",             :limit => 8
    t.string   "merchant_category_id"
    t.integer  "genre"
    t.integer  "account_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "trade_source_id"
    t.string   "shop_name"
  end

  create_table "yihaodian_skus", :force => true do |t|
    t.string   "product_code",                   :null => false
    t.string   "product_cname",                  :null => false
    t.integer  "product_id",        :limit => 8
    t.string   "ean13"
    t.integer  "category_id",       :limit => 8
    t.integer  "can_sale"
    t.string   "outer_id"
    t.integer  "can_show"
    t.integer  "account_id"
    t.integer  "parent_product_id", :limit => 8
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "trade_source_id"
    t.string   "shop_name"
  end

end

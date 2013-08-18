class AddAccountIdIndex < ActiveRecord::Migration
  def up
    add_index "accounts_users", ["user_id", "account_id"],  :name => "index_accounts_users_on_account_id_and_user_id"
    add_index "onsite_service_areas", ["area_id", "account_id"],  :name => "index_onsite_service_areas_on_account_id_and_area_id"
    add_index "skus", ["product_id", "account_id"],  :name => "index_skus_on_account_id_and_product_id"
    add_index "stock_products", ["sku_id", "product_id"],  :name => "index_stock_products_on_sku_id_and_product_id"
    add_index "sellers_areas", ["area_id","seller_id"], :name => "index_sellers_areas_on_area_id_and_seller_id"
    add_index "areas", ["name","parent_id"], :name => "index_sellers_areas_on_name_and_parent_id"

    add_index :sellers, :account_id,  :name => "index_areas_on_account_id"
    add_index :sellers, :lft,  :name => "index_sellers_on_lft"
    add_index :sellers, :rgt,  :name => "index_sellers_on_rgt"
    add_index :sellers, :active,  :name => "index_sellers_on_active"
    add_index :sellers, :performance_score,  :name => "index_sellers_on_performance_score"

    add_index "stock_products", ["seller_id", "account_id"],  :name => "index_stock_products_on_account_id_and_seller_id"
    add_index "sku_bindings", ["sku_id", "taobao_sku_id"],  :name => "index_stock_sku_bindings_on_sku_id_and_taobao_sku_id"

    add_index :areas, :seller_id,  :name => "index_areas_on_seller_id"
    add_index :areas, :lft,  :name => "index_areas_on_lft"
    add_index :areas, :rgt,  :name => "index_areas_on_rgt"
    add_index :categories, :lft,  :name => "index_categories_on_lgt"
    add_index :categories, :rgt,  :name => "index_categories_on_rgt"
    add_index :categories, :account_id,  :name => "index_categories_on_account_id"
    add_index :logistic_areas, :account_id,  :name => "index_logistic_areas_on_account_id"
    add_index :logistics, :account_id,  :name => "index_logistics_on_account_id"

    add_index :products, :outer_id,  :name => "index_products_on_outer_id"
    add_index :products, :storage_num,  :name => "index_products_on_storage_num"
    add_index :products, :category_id,  :name => "index_products_on_category_id"
    add_index :products, :num_iid,  :name => "index_products_on_num_iid"
    add_index :products, :account_id,  :name => "index_products_on_account_id"

    add_index :taobao_products, :outer_id,  :name => "index_taobao_products_on_outer_id"
    add_index :taobao_products, :category_id,  :name => "index_taobao_products_on_category_id"
    add_index :taobao_products, :account_id,  :name => "index_taobao_products_on_account_id"

    add_index :skus, :product_id,  :name => "index_skus_on_product_id"
    add_index :skus, :num_iid,  :name => "index_skus_on_num_iid"
    add_index :skus, :account_id,  :name => "index_skus_on_account_id"
    add_index :skus, :sku_id,  :name => "index_skus_on_sku_id"

    add_index :taobao_skus, :taobao_product_id,  :name => "index_taobao_skus_on_taobao_product_id"
    add_index :taobao_skus, :num_iid,  :name => "index_taobao_skus_on_num_iid"
    add_index :taobao_skus, :account_id,  :name => "index_taobao_skus_on_account_id"
    add_index :taobao_skus, :sku_id,  :name => "index_taobao_skus_on_sku_id"

    add_index :taobao_app_tokens, :account_id,  :name => "index_taobao_app_tokens_on_account_id"
    add_index :taobao_app_tokens, :trade_source_id,  :name => "index_taobao_app_tokens_on_trade_source_id"

    add_index :trade_sources, :account_id,  :name => "index_trade_sources_on_account_id"

  end

  def down
    remove_index "accounts_users", ["user_id", "account_id"],  :name => "index_accounts_users_on_account_id_and_user_id"
    remove_index "onsite_service_areas", ["area_id", "account_id"],  :name => "index_onsite_service_areas_on_account_id_and_area_id"
    remove_index "skus", ["product_id", "account_id"],  :name => "index_skus_on_account_id_and_product_id"
    remove_index "stock_products", ["sku_id", "product_id"],  :name => "index_stock_products_on_sku_id_and_product_id"
    remove_index "sellers_areas", ["area_id","seller_id"], :name => "index_sellers_areas_on_area_id_and_seller_id"
    remove_index "areas", ["name","parent_id"], :name => "index_sellers_areas_on_name_and_parent_id"

    remove_index :sellers, :account_id,  :name => "index_areas_on_account_id"
    remove_index :sellers, :lft,  :name => "index_sellers_on_lft"
    remove_index :sellers, :rgt,  :name => "index_sellers_on_rgt"
    remove_index :sellers, :active,  :name => "index_sellers_on_active"
    remove_index :sellers, :performance_score,  :name => "index_sellers_on_performance_score"

    remove_index "stock_products", ["seller_id", "account_id"],  :name => "index_stock_products_on_account_id_and_seller_id"
    remove_index "sku_bindings", ["sku_id", "taobao_sku_id"],  :name => "index_stock_sku_bindings_on_sku_id_and_taobao_sku_id"

    remove_index :areas, :seller_id,  :name => "index_areas_on_seller_id"
    remove_index :areas, :lft,  :name => "index_areas_on_lft"
    remove_index :areas, :rgt,  :name => "index_areas_on_rgt"
    remove_index :categories, :lft,  :name => "index_categories_on_lgt"
    remove_index :categories, :rgt,  :name => "index_categories_on_rgt"
    remove_index :categories, :account_id,  :name => "index_categories_on_account_id"
    remove_index :logistic_areas, :account_id,  :name => "index_logistic_areas_on_account_id"
    remove_index :logistics, :account_id,  :name => "index_logistics_on_account_id"

    remove_index :products, :outer_id,  :name => "index_products_on_outer_id"
    remove_index :products, :storage_num,  :name => "index_products_on_storage_num"
    remove_index :products, :category_id,  :name => "index_products_on_category_id"
    remove_index :products, :num_iid,  :name => "index_products_on_num_iid"
    remove_index :products, :account_id,  :name => "index_products_on_account_id"

    remove_index :taobao_products, :outer_id,  :name => "index_taobao_products_on_outer_id"
    remove_index :taobao_products, :category_id,  :name => "index_taobao_products_on_category_id"
    remove_index :taobao_products, :account_id,  :name => "index_taobao_products_on_account_id"

    remove_index :skus, :product_id,  :name => "index_skus_on_product_id"
    remove_index :skus, :num_iid,  :name => "index_skus_on_num_iid"
    remove_index :skus, :account_id,  :name => "index_skus_on_account_id"
    remove_index :skus, :sku_id,  :name => "index_skus_on_sku_id"

    remove_index :taobao_skus, :taobao_product_id,  :name => "index_taobao_skus_on_taobao_product_id"
    remove_index :taobao_skus, :num_iid,  :name => "index_taobao_skus_on_num_iid"
    remove_index :taobao_skus, :account_id,  :name => "index_taobao_skus_on_account_id"
    remove_index :taobao_skus, :sku_id,  :name => "index_taobao_skus_on_sku_id"

    remove_index :taobao_app_tokens, :account_id,  :name => "index_taobao_app_tokens_on_account_id"
    remove_index :taobao_app_tokens, :trade_source_id,  :name => "index_taobao_app_tokens_on_trade_source_id"

    remove_index :trade_sources, :account_id,  :name => "index_trade_sources_on_account_id"
  end
end

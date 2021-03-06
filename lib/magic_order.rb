#encoding: utf-8
module MagicOrder
  ## 别名
  # 一个action控制多个action, 比如一个编辑的权限应该有edit,和update权限,  那么可以自定义个key(下面hash中的key), 然后value(数组)中的是对应访问的权限action
  ActionDelega = {
    # TODO detail 放代表性的action, 不相关的放到其他的 别名中
    "detail" =>   ["index","home",'show','info','lastest','closed', 'children','fetch_group'],
    "create" =>   ["new","create","index"],
    "update" =>   ["edit","update", 'status_update',"index"],
    "destroy" =>  ["destroy","index"],
    "active" =>   ["active", "active_seller"],
    "shutdown" =>   ["shutdown", "shutdown_seller"],
    "destroy" =>  ["destroy","delete","deletes"],
    "user_manage" =>  ["seller_user_list","seller_user","remove_seller_user"],
    "area_manage" =>  ["create_seller_area","remove_seller_area", "seller_area"],
    "export" => ["export"],
    "import" => ["import","confirm_import_csv","import_csv"],
    "edit_depot" => ["edit_depot","update_depot"],
    "customers_detail" => ["index","potential","paid","around","show"],
    "send_customers_messages" => ["send_messages","invoice_messages","get_recipients"],
    "taobao_bind" => ["change_taobao_skus", "tie_to_native_skus", "taobao_skus"],
    "jingdong_bind" => ["change_jingdong_skus", "tie_to_native_skus", "jingdong_skus"],
    "yihaodian_bind" => ["change_yihaodian_skus", "tie_to_native_skus", "yihaodian_skus"],
    'refund_products_fetch' => %w(refund_fetch refund_save),
    'warehouse_management' => %(show enable_third_party_stock),
    'splited' => %w(split)

  }.freeze

  DefaultAccesses = {
    "logistics" => ["logistic_templates",
                    "user_list",
                    "all_logistics"],
    "categories" => ["autocomplete",
                    "category_templates",
                    "same_level_categories",
                    "product_templates",
                    "sku_templates"],
    "sales" => ["add_node"],
    "users" => ["autologin",
                "search",
                "edit_with_role",
                "sale_areas"],
    "products" => ["fetch_products",
                   "pick_product",
                   "abandon_product",
                   "fetch_category_properties",
                   "search_native_skus"],
    "print_flash_settings" => ["print_infos",
                               "info_list"]
  }.freeze

  class AccessControl
    class << self
      def map
        mapper = Mapping.new
        yield mapper
        @permissions ||= []
        @permissions += mapper.mapped_permissions
      end
      def permissions
        @permissions
      end
    end
  end

  class Mapping
    def initialize
      @project_module = nil
    end

    def permission(name,arys, options={})
      @permissions ||= []
      options.merge!(:project_module => @project_module)
      @permissions << Permission.new(name, arys, options)
    end

    def project_module(name,options={})
      @project_module = name
      yield self
      @project_module = nil
    end

    def mapped_permissions
      @permissions
    end
  end

  class Permission
    attr_reader :name, :actions, :project_module
    def initialize(name,arys,options={})
      @name = name
      @actions = arys.flatten
      @project_module = options[:project_module]
    end
  end
end

# modes 不同模式下可见订单列
# oerations 不同角色显示的“操作”弹出项
# "a#b"  a => 控制器,  "b" => action or ActionDelega(请看最上面) key
MagicOrder::AccessControl.map do |map|

  #通知中心
  map.project_module :notifications do |map|
    map.permission :reads, %w(detail)
  end

  #订单管理
  map.project_module :trades do |map|
    map.permission :reads,      ["detail",
                                 'request_add_ref',
                                 'confirm_add_ref',
                                 'request_return_ref',
                                 'confirm_return_ref',
                                 'cancel_return_ref',
                                 'request_refund_ref',
                                 'confirm_refund_ref',
                                 'cancel_refund_ref']
    map.permission :operations, ["add_ref",
                                 "return_ref",
                                 "refund_ref",
                                 "edit_handmade_trade",
                                 "create_handmade_trade",
                                 "trade_finished",
                                 "lock_trade",
                                 "activate_trade",
                                 "export_orders",
                                 "batch_export",
                                 "batch_add_gift",
                                 "logistic_waybill",
                                 "seller",
                                 "cs_memo",
                                 "mark_unusual_state",
                                 "check_goods",
                                 "operation_log",
                                 "manual_sms_or_email",
                                 "print_deliver_bill",
                                 "deliver",
                                 "seller_confirm_invoice",
                                 "seller_confirm_deliver",
                                 "request_return",
                                 "confirm_refund",
                                 "gift_memo",
                                 "setup_logistic",
                                 "logistic_split",
                                 "print_logistic_bill",
                                 "modify_receiver_information",
                                 "merge_trades_manually",
                                 "split_merged_trades",
                                 "invoice",
                                 "split_invoice",
                                 "split_trade",
                                 "revoke_split_trade",
                                 "property_memo",
                                 "print_deliver_bill",
                                 "print_process_sheet"]
  end

  #商品管理
  map.project_module :products do |map|
    map.permission :reads,      ["detail",
                                 "taobao_products",
                                 "taobao_product",
                                 "jingdong_products#detail",
                                 "jingdong_products#sync",
                                 "yihaodian_products#detail",
                                 "yihaodian_products#sync"
                                ]
    map.permission :operations, ["create",
                                 "update",
                                 "import",
                                 "export_products",
                                 "update_on_sale",
                                 "taobao_bind",
                                 "sync_taobao_products",
                                 "taobao_sync_versions",
                                 "remove_sku",
                                 "add_sku",
                                 "jingdong_products#sync_history",
                                 "jingdong_products#jingdong_bind",
                                 "yihaodian_products#sync_history",
                                 "yihaodian_products#yihaodian_bind"
                                ]

  end

  #经销商管理
  map.project_module :sellers do |map|
    map.permission :reads,      ["detail"]
    map.permission :operations, ["create",
                                 "update",
                                 "export",
                                 "import",
                                 "user_manage",
                                 "area_manage",
                                 "active",
                                 "shutdown"]

  end

  #运营商对账
  map.project_module :reconcile_statements do |map|
    map.permission :reconcile_operators,   ["reconcile_statements#index",
                                            "reconcile_statements#exports",
                                            "reconcile_statements#confirm_process",
                                            "reconcile_statements#confirm_audit",
                                            "reconcile_statements#change_detail"]
    map.permission :reconcile_sellers,     ["reconcile_statements#seller_index",
                                            "reconcile_statements#seller_exports",
                                            "reconcile_statements#confirm_process",
                                            "reconcile_statements#confirm_seller_audit",
                                            "reconcile_statements#update_processed",
                                            "reconcile_statements#product_detail_exports",
                                            "reconcile_statements#change_product_details"]
  end

  #
  map.project_module :export_form do |map|
    map.permission :operations,    ["type",
                                    "tid", 
                                    "status", 
                                    "created_time",
                                    "pay_time", 
                                    "dispatched_at", 
                                    "delivered_at", 
                                    "end_time", 
                                    "seller_name", 
                                    "receiver_state", 
                                    "receiver_city", 
                                    "receiver_district", 
                                    "receiver_address", 
                                    "receiver_name", 
                                    "buyer_nick", 
                                    "receiver_mobile", 
                                    "receiver_phone", 
                                    "title", 
                                    "item_outer_id",
                                    "sku_properties", 
                                    "num", 
                                    "native_name", 
                                    "native_outer_id", 
                                    "native_number",
                                    "native_sku_properties",
                                    "native_property_memos_text", 
                                    "logistic_name", 
                                    "logistic_waybill", 
                                    "order_price", 
                                    "vip_discount", 
                                    "shop_bonus", 
                                    "shop_discount", 
                                    "other_discount", 
                                    "post_fee", 
                                    "total_fee", 
                                    "payment", 
                                    "more_refund", 
                                    "less_patch", 
                                    "buyer_message", 
                                    "cs_memo", 
                                    "gift_memo", 
                                    "invoice_name",
                                    "refund_status_text", 
                                    "batch_num",
                                    "serial_num",
                                    "order_rate_info_result", 
                                    "order_rate_info_content", 
                                    "order_rate_info_create"]
  end

  #地区管理
  map.project_module :areas do |map|
    map.permission :reads,      ["detail",
                                 "autocomplete",
                                 "area_search",
                                 "sellers"]
    map.permission :operations, ["create",
                                 "update",
                                 "import",
                                 "export"]
  end

  #发货拆分管理
  map.project_module :logistic_groups do |map|
    map.permission :reads,      ["detail"]
    map.permission :operations, ["create",
                                 "destroy"]
  end

  #发货单模版管理
  map.project_module :deliver_templates do |map|
    map.permission :reads,      ["detail"]
    map.permission :operations, ["change_default_template"]
  end

  #仓库模块
  map.project_module :stocks do |map|
    map.permission :reads,      ["warehouses#index",
                                 "detail",
                                 "stock_in_bills#detail",
                                 "stock_out_bills#detail",
                                 "stock_bills#detail",
                                 "refund_products#detail"
                               ]
    map.permission :operations, [
                                 "audit",
                                 "sync",
                                 "batch_update_safety_stock",
                                 "batch_update_actual_stock",
                                 "stock_bills#get_products",
                                 "stock_in_bills#create",
                                 "stock_in_bills#sync",
                                 "stock_in_bills#update",
                                 "stock_in_bills#check",
                                 "stock_in_bills#rollback",
                                 "stock_in_bills#lock",
                                 "stock_in_bills#unlock",
                                 # "stock_in_bills#confirm_sync",
                                 "stock_in_bills#confirm_stock",
                                 # "stock_in_bills#confirm_cancle",
                                 # "stock_in_bills#refuse_cancle",
                                 "stock_out_bills#create",
                                 "stock_out_bills#update",
                                 "stock_out_bills#sync",
                                 "stock_out_bills#check",
                                 "stock_out_bills#rollback",
                                 "stock_out_bills#lock",
                                 "stock_out_bills#unlock",
                                 # "stock_out_bills#confirm_sync",
                                 "stock_out_bills#confirm_stock",
                                 # "stock_out_bills#confirm_cancle",
                                 # "stock_out_bills#refuse_cancle",
                                 "stock_products#inventory",
                                 "refund_products#create",
                                 "refund_products#update",
                                 "refund_products#sync",
                                 "refund_products#check",
                                 "refund_products#rollback",
                                 "refund_products#locking",
                                 "refund_products#enable",
                                 "refund_products#refund_products_fetch",
                                 "refund_products#confirm_recognize"
                               ]
  end
  #数据模块
  map.project_module :datas do |map|
    map.permission :reads,      [#"user_activities#detail",
                                 #"user_activities#all",
                                 "sales#summary",
                                 "trade_reports#detail",
                                 "sales#product_analysis",
                                 "sales#detail",
                                 "sales#update",
                                 "sales#area_analysis",
                                 "sales#time_analysis",
                                 "sales#price_analysis",
                                 "sales#frequency_analysis",
                                 "sales#univalent_analysis"]
    map.permission :operations, ["trade_reports#download",
                                 "customers#customers_detail",
                                 "customers#send_customers_messages"
                                ]
  end
  #系统设置
  map.project_module :system_settings do |map|
    map.permission :reads,      ["users#detail",
                                 "users#roles",
                                 "users#limits",
                                 "users#seller_areas",
                                 "areas#detail",
                                 "logistics#detail",
                                 "account_setups#edit_auto_settings",
                                 "logistics#logistic_user",
                                 "categories#detail"
                               ]
    map.permission :operations, ["users#update",
                                 "users#delete",
                                 "users#batch_update",
                                 "users#create",
                                 "users#create_role",
                                 "users#destroy_role",
                                 "logistics#update",
                                 "logistics#create",
                                 "logistics#destroy",
                                 "logistics#create_logistic_area",
                                 "logistics#remove_logistic_area",
                                 "logistics#logistic_user_list",
                                 "logistics#remove_logistic_user",
                                 "logistics#logistic_user",
                                 "logistic_areas#index",
                                 "logistic_areas#update_post_info",
                                 "print_flash_settings#show",
                                 "print_flash_settings#update_infos",
                                 "account_setups#update_auto_settings",
                                 "users#update_permissions",
                                 "categories#update",
                                 "categories#create",
                                 "categories#destroy",
                                 "trade_types#create",
                                 "trade_types#update",
                                 "trade_types#destroy",
                                 "wm#warehouse_management"
                               ]
  end
end
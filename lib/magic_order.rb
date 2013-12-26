#encoding: utf-8
module MagicOrder
  ActionDelega = {
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
    'refund_products_fetch' => %w(refund_fetch refund_save)

  }.freeze

  DefaultAccesses = {
    "logistics" => ["logistic_templates",
                    "user_list",
                    "all_logistics"],
    "categories" => ["autocomplete",
                    "category_templates",
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
                   "search_native_skus"]
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

#modes 不同模式下可见订单列
#oerations 不同角色显示的“操作”弹出项
MagicOrder::AccessControl.map do |map|

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
    # map.permission :operations, ["logistic_waybill",
    #                              "seller",
    #                              "cs_memo",
    #                              "color",
    #                              "invoice",
    #                              "trade_split",
    #                              "recover",
    #                              "mark_unusual_state",
    #                              "reassign",
    #                              "refund",
    #                              "check_goods",
    #                              "operation_log",
    #                              "manual_sms_or_email",
    #                              "print_deliver_bill",
    #                              "deliver",
    #                              "confirm_color",
    #                              "seller_confirm_invoice",
    #                              "confirm_receive",
    #                              "logistic_memo",
    #                              "barcode",
    #                              "seller_confirm_deliver",
    #                              "request_return",
    #                              "confirm_return",
    #                              "confirm_refund",
    #                              "gift_memo",
    #                              "modify_payment",
    #                              "setup_logistic",
    #                              "logistic_split",
    #                              "print_logistic_bill",
    #                              "confirm_check_goods"]
    map.permission :operations, ["add_ref",
                                 "return_ref",
                                 "refund_ref",
                                 "edit_handmade_trade",
                                 "create_handmade_trade",
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
                                 "split_invoice"]
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
                                 "confirm_sync",
                                 "remove_sku",
                                 "add_sku",
                                 "jingdong_products#syncing",
                                 "jingdong_products#jingdong_bind",
                                 "yihaodian_products#syncing",
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
    # map.permission :operations, ["create",
    #                              "update",
    #                              "destroy"]
    map.permission :operations, [#"edit_depot",
                                 "audit",
                                 "sync",
                                 "batch_update_safety_stock",
                                 "batch_update_actual_stock",
                                 "new_single_storage",
                                 "new_storehouse",
                                 "increase_in_commodity",
                                 "determine_the_library",
                                 "determine_the_storage",
                                 "stock_in_bills#create",
                                 "stock_out_bills#create",
                                 "stock_in_bills#update",
                                 "stock_out_bills#update",
                                 "stock_in_bills#sync",
                                 "stock_out_bills#sync",
                                 "stock_in_bills#check",
                                 "stock_out_bills#check",
                                 "stock_in_bills#rollback",
                                 "stock_out_bills#rollback",
                                 "stock_in_bills#lock",
                                 "stock_out_bills#lock",
                                 "stock_in_bills#unlock",
                                 "stock_out_bills#unlock",
                                 "stock_products#inventory",
                                 "refund_products#create",
                                 "refund_products#update",
                                 "refund_products#sync",
                                 "refund_products#check",
                                 "refund_products#rollback",
                                 "refund_products#locking",
                                 "refund_products#enable",
                                 "refund_products#refund_products_fetch"
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
                                 "account_setups#update_auto_settings",
                                 "users#update_permissions",
                                 "categories#update",
                                 "categories#create",
                                 "categories#destroy",
                                 "trade_types#create",
                                 "trade_types#update",
                                 "trade_types#destroy"
                               ]
  end

#  map.project_module :logistics do |map|
#    map.permission :reads,      ["detail"]
#    map.permission :operations, ["create","update","destroy"]
#  end

#  map.project_module :logistic do |map|
#    map.permission :operations, ["detail", "logistic_waybill", "confirm_receive", "logistic_memo"]
#  end

#  map.project_module :trades do |map|
#    map.permission :operations, ["deliver", "logistic_waybill", "confirm_receive", "logistic_memo", "detail", "seller", "cs_memo", "color", "invoice", "trade_split", "recover", "mark_unusual_state", "reassign", "request_return", "confirm_return", "check_goods", "deliver", "seller_confirm_deliver", "seller_confirm_invoice", "barcode", "check_goods", "logistic_split", "print_logistic_bill", "print_deliver_bill", "confirm_refund", "operation_log", "manual_sms_or_email","confirm_color","confirm_check_goods", "logistic_waybill", "gift_memo", "modify_payment"]
#    map.permission :modes,      ['trade_source','deliver_bill','tid','status','status_history','receiver_id','receiver_name','receiver_mobile_phone','receiver_address','buyer_message','seller_memo','cs_memo','gift_memo','color_info','invoice_info','point_fee', 'total_fee','seller','logistic', 'logistic_waybill']
#  end
#
#  map.project_module :deliver do |map|
#    map.permission :operations, ["detail", "print_deliver_bill"]
#    map.permission :modes     , ['tid','status','status_history','deliver_bill_id','deliver_bill_status','trade_source','order_goods','receiver_name','receiver_mobile_phone','receiver_address','color_info','invoice_info','seller','cs_memo','logistic']
#  end
#
#  map.project_module :logistics do |map|
#    map.permission :operations, ["detail", "setup_logistic", "confirm_receive", "logistic_memo", "print_logistic_bill"]
#    map.permission :modes     , ['trade_source','tid','status','logistic_bill_status','status_history','receiver_id','receiver_name','receiver_mobile_phone','receiver_address','order_goods','color_info','seller','logistic','logistic_waybill']
#  end
#
#
#  map.project_module :check do |map|
#    map.permission :operations, ["detail"]
#    map.permission :modes     , ['tid','status','deliver_bill_id','status_history','deliver_bill_status','trade_source','order_goods','receiver_name','receiver_mobile_phone','receiver_address','color_info','invoice_info','seller','cs_memo'  ]
#  end
#
#
#  map.project_module :send do |map|
#    map.permission :operations, ["deliver", "logistic_waybill", "seller_confirm_deliver","detail"]
#    map.permission :modes     , ['tid','status','deliver_bill_id','status_history','order_goods','receiver_name','receiver_mobile_phone','receiver_address','color_info','invoice_info','seller','cs_memo']
#  end
#
#  map.project_module :return do |map|
#    map.permission :operations, ["detail","confirm_return"]
#    map.permission :modes, ['tid','status','deliver_bill_id','status_history','order_goods','receiver_name','receiver_mobile_phone','receiver_address','color_info','invoice_info','seller','cs_memo']
#  end
#
#
#  map.project_module :refund do |map|
#    map.permission :operations, ["detail"]
#    map.permission :modes, ['tid','status','deliver_bill_id','status_history','order_goods','receiver_name','receiver_mobile_phone','receiver_address','color_info','invoice_info','seller','cs_memo']
#  end
#
#
#  map.project_module :invoice do |map|
#    map.permission :operations, ["invoice_number","detail"]
#    map.permission :modes     , ['tid','status','deliver_bill_id','status_history','trade_source','order_goods','invoice_type','invoice_name','invoice_value','invoice_date','seller','cs_memo'  ]
#  end
#
#  map.project_module :unusual do |map|
#    map.permission :operations, ["detail", "mark_unusual_state"]
#    map.permission :modes, ['trade_source','tid','status','status_history','receiver_id','receiver_name','receiver_mobile_phone','receiver_address','buyer_message','seller_memo','cs_memo','color_info','invoice_info','deliver_bill','logistic_bill','seller','order_split']
#  end
#
#  map.project_module :color do |map|
#    map.permission :operations, ["color","confirm_color","detail"]
#    map.permission :modes,      ['tid','status','deliver_bill_id','status_history','order_goods','receiver_name','receiver_mobile_phone','receiver_address','color_info','invoice_info','seller','cs_memo']
#  end
end
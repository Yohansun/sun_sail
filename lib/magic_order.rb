#encoding: utf-8
module MagicOrder
  ActionDelega = {"detail" => ["index","home",'show'],"create" => ["new","create"],"update" => ["edit","update"],"destroy" => ["destroy","delete"]}.freeze
              
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
  map.project_module :trades do |map|
    map.permission :reads,      ["detail"]
#    map.permission :operations, ["logistic_waybill", "seller", "cs_memo", "color", "invoice", "trade_split", "recover", "mark_unusual_state", "reassign", "refund", "check_goods", "operation_log", "manual_sms_or_email", "print_deliver_bill", "deliver", "confirm_color", "seller_confirm_invoice", "confirm_receive", "logistic_memo", "barcode", "seller_confirm_deliver", "request_return", "confirm_return", "confirm_refund", "gift_memo", "modify_payment", "setup_logistic", "logistic_split", "print_logistic_bill", "confirm_check_goods"]
    map.permission :operations, ["logistic_waybill", "seller", "cs_memo", "mark_unusual_state", "check_goods", "operation_log", "manual_sms_or_email", "print_deliver_bill", "deliver", "seller_confirm_invoice", "seller_confirm_deliver", "request_return", "confirm_refund", "gift_memo", "setup_logistic", "logistic_split", "print_logistic_bill"]
  end
  map.project_module :products do |map|
    map.permission :reads,      ["detail","taobao_products"]
    map.permission :operations, ["create","update","export_products","update_on_sale","tie_to_native_skus"]

  end
  
  map.project_module :stocks do |map|
    map.permission :reads,      ["detail","stock_in_bills#detail","stock_out_bills#detail","stock_bills#detail"]
#    map.permission :operations, ["create","update","destroy"]
    map.permission :operations, ["audit","sync","new_single_storage","new_storehouse","increase_in_commodity","determine_the_library","determine_the_storage",
      "stock_in_bills#create","stock_out_bills#create","stock_in_bills#sync","stock_out_bills#sync","stock_in_bills#check","stock_out_bills#check","stock_in_bills#rollback",
      "stock_out_bills#rollback","stock_in_bills#add_product","stock_out_bills#add_product","stock_in_bills#remove_product","stock_out_bills#remove_product"]
  end
  
  map.project_module :datas do |map|
    map.permission :reads,      ["user_activities#detail","user_activities#all","trade_reports#detail","sales#product_analysis"]
    map.permission :operations, ["reports#download"]
  end
  
  map.project_module :system_settings do |map|
    map.permission :reads,      ["users#detail","users#roles","users#limits","areas#detail","logistics#detail","account_setups#edit_auto_settings","logistics#logistic_user","categories#detail"]
    map.permission :operations, ["users#update","users#delete","users#batch_update","users#create","users#destroy_role","logistics#update","logistics#delete","logistics#create_logistic_area",
      "logistics#remove_logistic_area","logistics#logistic_user_list","logistics#remove_logistic_user","logistics#logistic_user","account_setups#update_auto_settings","users#update_permissions",
      "categories#update","categories#create","categories#destroy"]
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
#    map.permission :operations, ["detail", "setup_logistic","logistic_waybill", "confirm_receive", "logistic_memo", "print_logistic_bill"]
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
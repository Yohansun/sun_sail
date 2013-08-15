#encoding: utf-8
# == Schema Information
#
# Table name: accounts
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  key               :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  seller_name       :string(255)
#  address           :string(255)
#  phone             :string(255)
#  deliver_bill_info :string(255)
#  point_out         :string(255)
#  website           :string(255)
#


# == Schema Information
#
# Table name: accounts
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  key        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#
class Account < ActiveRecord::Base
  include RailsSettings

  attr_accessible :key, :name, :seller_name, :address, :deliver_bill_info, :phone, :website, :point_out

  has_and_belongs_to_many :users

  has_many :bbs_categories
  has_many :bbs_topics
  has_many :categories
  has_many :colors
  has_many :packages
  has_many :products
  has_many :taobao_products
  has_many :quantities
  has_many :sales
  has_many :sellers
  has_many :settings
  has_many :stocks
  has_many :stock_histories
  has_many :stock_products
  has_many :features
  has_many :reconcile_statements
  has_many :logistics
  has_many :logistic_areas
  has_many :onsite_service_areas
  has_many :logistic_rates
  has_many :logistic_groups
  has_many :trade_sources
  has_many :roles, :dependent => :destroy
  has_many :skus
  has_many :taobao_skus
  has_one :trade_source

  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  after_create :create_default_roles,:init_settings,:create_default_seller

  def in_time_gap(start_at, end_at)
    if start_at != nil && end_at != nil
      if start_at < end_at
        start_time = (Time.now.to_date.to_s + " " + start_at).to_time(:local).to_i
        end_time = (Time.now.to_date.to_s + " " + end_at).to_time(:local).to_i
        time_now = Time.now.to_i
        if time_now >= start_time && time_now <= end_time
          return true
        elsif time_now < start_time
          return (start_time - time_now)
        elsif time_now > end_time
          return (86400 + start_time - time_now)
        end
      elsif start_at > end_at
        time_now = Time.now.strftime("%H:%M:%S")
        if time_now >= end_at && time_now <= start_at
          start_time = (Time.now.to_date.to_s + " " + start_at).to_time(:local).to_i
          time_now = (Time.now.to_date.to_s + " " + time_now).to_time(:local).to_i
          return (start_time - time_now)
        else
          return true
        end
      end
    else
      return true # default gap is all day
    end
  end

  def can_auto_preprocess_right_now
    return in_time_gap(self.settings.auto_settings["start_preprocess_at"], self.settings.auto_settings["end_preprocess_at"])
  end

  def can_auto_dispatch_right_now
    return in_time_gap(self.settings.auto_settings["start_dispatch_at"], self.settings.auto_settings["end_dispatch_at"])
  end

  def can_auto_deliver_right_now
    return in_time_gap(self.settings.auto_settings["start_deliver_at"], self.settings.auto_settings["end_deliver_at"])
  end

  def setting_values
    [
      ["auto_settings",{'split_conditions' => {},
                        'dispatch_conditions'=>{},
                        'unusual_conditions'=>{}}],
      ["trade_modes",{"trades"=>"订单模式",
                      "deliver"=>"发货单模式",
                      "logistics"=>"物流单模式",
                      "check"=>"验货模式",
                      "send"=>"发货模式",
                      "return"=>"退货模式",
                      "refund"=>"退款模式",
                      "invoice"=>"发票模式",
                      "unusual"=>"异常模式"}],
      ["trade_cols_visible_modes",{"trades"=>["trade_source",
                                              "tid",
                                              "status",
                                              "status_history",
                                              "receiver_id",
                                              "receiver_address",
                                              "seller_memo",
                                              "cs_memo",
                                              "gift_memo",
                                              "invoice_info",
                                              "point_fee",
                                              "operator",
                                              "seller",
                                              "logistic"],
                                   "deliver_bills"=>["tid",
                                                     "deliver_bill_id",
                                                     "deliver_bill_status",
                                                     "trade_source",
                                                     "order_goods",
                                                     "receiver_name",
                                                     "receiver_address"],
                                   "logistic_bills"=>["trade_source",
                                                      "tid",
                                                      "logistic_bill_status",
                                                      "receiver_name",
                                                      "receiver_address",
                                                      "order_goods",
                                                      "logistic"],
                                   "check"=>["tid",
                                             "status",
                                             "deliver_bill_id",
                                             "status_history",
                                             "deliver_bill_status",
                                             "trade_source",
                                             "order_goods",
                                             "receiver_name",
                                             "receiver_mobile_phone",
                                             "receiver_address",
                                             "invoice_info",
                                             "seller",
                                             "cs_memo"],
                                   "send"=>["tid",
                                            "status",
                                            "deliver_bill_id",
                                            "status_history",
                                            "order_goods",
                                            "receiver_name",
                                            "receiver_mobile_phone",
                                            "receiver_address",
                                            "invoice_info",
                                            "seller",
                                            "cs_memo"],
                                   "return"=>["tid",
                                              "status",
                                              "deliver_bill_id",
                                              "status_history",
                                              "order_goods",
                                              "receiver_name",
                                              "receiver_mobile_phone",
                                              "receiver_address",
                                              "invoice_info",
                                              "seller",
                                              "cs_memo"],
                                   "refund"=>["tid",
                                              "status",
                                              "deliver_bill_id",
                                              "status_history",
                                              "order_goods",
                                              "receiver_name",
                                              "receiver_mobile_phone",
                                              "receiver_address",
                                              "invoice_info",
                                              "seller",
                                              "cs_memo"],
                                   "invoice"=>["tid",
                                               "status",
                                               "deliver_bill_id",
                                               "status_history",
                                               "trade_source",
                                               "order_goods",
                                               "invoice_type",
                                               "invoice_name",
                                               "invoice_value",
                                               "invoice_date",
                                               "seller",
                                               "cs_memo"],
                                   "unusual"=>["trade_source",
                                               "tid",
                                               "status",
                                               "status_history",
                                               "receiver_id",
                                               "receiver_name",
                                               "receiver_mobile_phone",
                                               "receiver_address",
                                               "buyer_message",
                                               "seller_memo",
                                               "cs_memo",
                                               "invoice_info",
                                               "deliver_bill",
                                               "logistic_bill",
                                               "seller"]}],

      ["trade_cols",{"trade_source"=>"订单来源",
                     "tid"=>"订单编号",
                     "status"=>"当前状态",
                     "status_history"=>"历史状态",
                     "order_goods"=>"商品详细",
                     "receiver_name"=>"客户ID(客户姓名)",
                     "receiver_address"=>"联系地址(联系电话)",
                     "seller_memo"=>"卖家备注",
                     "cs_memo"=>"客服备注",
                     "buyer_message"=>"客户留言",
                     "gift_memo"=>"赠品备注",
                     "invoice_info"=>"发票信息",
                     "point_fee"=>"使用积分",
                     "operator"=>"操作人",
                     "total_fee"=>"实付金额",
                     "seller"=>"配送经销商(上级经销商)",
                     "logistic"=>"物流配送商(物流单号)",
                     "deliver_bill_id"=>"发货单编号",
                     "deliver_bill_status"=>"发货单状态",
                     "logistic_bill_status"=>"物流单状态",
                     "deliver_bill"=>"发货单",
                     "logistic_bill"=>"物流单",
                     "invoice_type"=>"发票类型",
                     "invoice_name"=>"发票开头",
                     "invoice_value"=>"开票金额",
                     "invoice_date"=>"完成日期"}],
      ["customer_cols", {"name" => "顾客昵称",
          "receiver_mobile" => "顾客联系电话",
          "receiver_state" => "（收货）省",
          "receiver_city" => "（收货）市",
          "receiver_district" => "（收货）区",
          "receiver_address" => "（收货）地址"}],
      ["customer_around_cols", {"name" => "顾客昵称",
          "receiver_mobile" => "联系电话",
          "trade_id" => "订单编号",
          "product_name" => "购买商品",
          "use_days" => "商品生命周期",
          "receiver_state" => "（收货）省",
          "receiver_city" => "（收货）市",
          "receiver_district" => "（收货）区",
          "receiver_address" => "（收货）地址"}],
      ["customer_visible_cols", {"index" => ["name",
                                    "receiver_mobile",
                                    "receiver_state",
                                    "receiver_city",
                                    "receiver_district",
                                    "receiver_address"],
                                  "potential" => ["name",
                                    "receiver_mobile",
                                    "receiver_state",
                                    "receiver_city",
                                    "receiver_district",
                                    "receiver_address"],
                                  "paid" => ["name",
                                    "receiver_mobile",
                                    "receiver_state",
                                    "receiver_city",
                                    "receiver_district",
                                    "receiver_address"],
                                  "around" => ["name",
                                    "receiver_mobile",
                                    "trade_id",
                                    "product_name",
                                    "use_days",
                                    "receiver_state",
                                    "receiver_city",
                                    "receiver_district",
                                    "receiver_address"]}],
      ["stock_in_bill_cols", {"stock_no" => "序号",
          "tid" => "入库单编号",
          "status" => "当前状态",
          "operation" => "历史状态",
          "stock_type_name" => "入库类型",
          "bill_products_mumber" => "商品数量",
          "bill_products_real_mumber" => "实际入库",
          "bill_products_price" => "商品总价"}],
      ["stock_in_bill_visible_cols", ["stock_no",
                                  "tid",
                                  "status",
                                  "operation",
                                  "stock_type_name",
                                  "bill_products_mumber",
                                  "bill_products_real_mumber",
                                  "bill_products_price"]],
      ["stock_out_bill_cols", {"stock_no" => "序号",
          "tid" => "出库单编号",
          "status" => "当前状态",
          "operation" => "历史状态",
          "stock_type_name" => "出库类型",
          "bill_products_mumber" => "商品数量",
          "bill_products_price" => "商品总价"}],
      ["stock_out_bill_visible_cols", ["stock_no",
                                  "tid",
                                  "status",
                                  "operation",
                                  "stock_type_name",
                                  "bill_products_mumber",
                                  "bill_products_price"]],
      ["stock_bill_cols", {"stock_no" => "序号",
          "tid" => "出/入库单编号",
          "status_text" => "状态",
          "product_sku" => "商品编码",
          "product_title" => "商品名称",
          "stock_type_name" => "类型",
          "created_at" => "创建时间",
          "stocked_at" => "出/入库时间"}],
      ["stock_bill_visible_cols", ["stock_no",
                                  "tid",
                                  "status_text",
                                  "product_sku",
                                  "product_title",
                                  "stock_type_name",
                                  "created_at",
                                  "stocked_at"]],
      ["stock_product_detail_cols", {"id" => "ID",
                            "sku_sku_id" => "SKU编码",
                            "product_name" => "商品SKU名称",
                            "product_outer_id" => "商品编码",
                            "category_name" => "商品分类",
                            "forecast" => "预测库存",
                            "activity" => "可用库存",
                            "actual" => "实际库存",
                            "safe_value" => "安全库存",
                            "storage_status" => "库存状态"}],
      ["stock_product_detail_visible_cols", ["id",
                                    "sku_sku_id",
                                    "product_name",
                                    "product_outer_id",
                                    "category_name",
                                    "forecast",
                                    "activity",
                                    "actual",
                                    "safe_value",
                                    "storage_status"]],
      ["stock_product_all_cols", {"id" => "ID",
                            "seller_id" => "经销商",
                            "product_name" => "商品SKU名称",
                            "forecast" => "预测库存",
                            "activity" => "可用库存",
                            "actual" => "实际库存",
                            "safe_value" => "安全库存"}],
      ["stock_product_all_visible_cols", ["id",
                                    "seller_id",
                                    "product_name",
                                    "forecast",
                                    "activity",
                                    "actual",
                                    "safe_value"]],
      ["product_cols", {"id" => "商品ID",
                            "name" => "商品名称",
                            "category_id" => "商品分类",
                            "outer_id" => "商品编码",
                            "category_property_names" => "商品属性",
                            "is_on_sale" => "是否上架"}],
      ["product_visible_cols", ["id",
                                    "name",
                                    "category_id",
                                    "outer_id",
                                    "category_property_names",
                                    "is_on_sale"]],
      ["taobao_product_cols", {"num_iid" => "淘宝数字ID",
                            "name" => "淘宝商品名",
                            "cat_name" => "商品类目名称",
                            "outer_id" => "商品外部编码",
                            "has_bindings" => "是否已绑定本地SKU"}],
      ["taobao_product_visible_cols", ["num_iid",
                                    "name",
                                    "cat_name",
                                    "outer_id",
                                    "has_bindings"]],
      ["enable_token_error_notify",true]
    ]
  end

  def init_settings
    setting_values.each{|key,value|
      self.settings[key] = value
    }
  end

  def create_default_seller
    self.sellers.create(name:self.name,fullname:self.name, has_stock:true, areas:Area.leaves)
  end

  def create_default_roles
    self.roles.create(:name=>:admin).add_all_permissions
  end
end

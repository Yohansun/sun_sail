# -*- encoding:utf-8 -*-

class YihaodianOrder < Order

  field :title,      as: :product_c_name,     type: String

  field :num,        as: :order_item_num,     type: Integer
  field :price,      as: :order_item_price,   type: Float
  field :num_iid,    as: :product_id,         type: String

  field :payment,    as: :order_item_amount,  type: Float

  #注意一号店的refund_status是整形
  field :product_refund_num, type: Integer

  #一号店子订单没有sku_id
  #field :sku_id,                         type: String

  #一号店子订单特有字段
  field :order_id,                  type: Integer      #订单id
  field :order_item_id,             type: Integer      #订单明细ID
  field :merchant_id,               type: Integer      #商家id
  field :original_price,            type: Float        #产品原价
  field :group_flag,                type: Integer      #团购产品标识，1表示团购产品,0表示非团购产品
  field :process_finish_date,       type: DateTime     #退换货完成时间
  field :update_time,               type: DateTime     #更新时间
  field :outer_id,                  type: String       #产品外部编码
  field :delivery_fee_amount,       type: Float        #商品运费分摊金额
  field :promotion_amount,          type: Float        #促销活动立减分摊金额
  field :coupon_amount_merchant,    type: Float        #商家抵用券分摊金额
  field :coupon_platform_discount,  type: Float        #1mall平台抵用券分摊金额
  field :subsidy_amount,            type: Float        #节能补贴金额


  enum_attr :group_flag, [["团购产品", 1],
                          ["非团购产品", 0]], not_valid: true

  embedded_in :yihaodian_trades

  before_save :set_refund_status

  def account_id
    yihaodian_trades.account_id
  end

  # def product
  #   super(outer_sku_id)
  # end

  def sku_properties_name
    #YIHAO PENDING
  end

  def sku_properties
    #YIHAO PENDING
  end

  def yihaodian_sku
    #YIHAO PENDING
  end

  def sku_bindings
    #YIHAO PENDING
  end

  def skus
    #YIHAO PENDING
  end

  def bill_info
    # tmp = {}
    # color_num.each do |nums|
    #   next if nums.blank?

    #   num = nums[0]
    #   next if num.blank?

    #   if tmp.has_key? num
    #     tmp["#{num}"][0] += 1
    #   else
    #     tmp["#{num}"] = [1, Color.find_by_num(num).try(:name)]
    #   end
    # end

    [{
      outer_id: '',
      number: 1,
      storage_num: '',
      title: title,
      colors: []
    }]
  end

  def refund_status_text
    if self.product_refund_num.present?
      yihaodian_trades.refund_status_name
    end
  end

  def set_refund_status
    if self.product_refund_num.present?
      self.refund_status = "HAS_REFUND_INFO"
    else
      self.refund_status = "NO_REFUND"
    end
  end

  def order_price
    price
  end

  def order_payment
    payment / num
  end

end
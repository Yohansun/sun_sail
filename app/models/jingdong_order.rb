# -*- encoding:utf-8 -*-

class JingdongOrder < Order

  field :sku_id,                         type: String
  field :outer_sku_id,                   type: String
  field :title,        as: :sku_name,    type: String # 商品的名称+SKU规格

  field :price,        as: :jd_price,    type: Float
  field :num,          as: :item_total,  type: Integer
  field :num_iid,      as: :ware_id,     type: String

  #京东子订单特有字段
  field :gift_point,                     type: String

  embedded_in :jingdong_trades

  def trade
    jingdong_trades
  end

  def account_id
    jingdong_trades.account_id
  end

  # def product
  #   super(outer_sku_id)
  # end

  def sku_properties_name
    #PENDING DO SOMETHING WITH THE SKU_NAME
    title
  end

  def sku_properties
    #PENDING
    title
  end

  def jingdong_sku
    scoped = JingdongSku.where(account_id: account_id)
    if sku_id.present?
      scoped.find_by_sku_id(sku_id)
    else
      scoped.find_by_ware_id(ware_id)
    end
  end

  def sku_bindings
    jingdong_sku.sku_bindings rescue []
  end

  def skus
    (jingdong_sku && jingdong_sku.skus) || local_skus || []
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
      title: sku_name,
      colors: []
    }]
  end

  def refund_status_text
    case self.refund_status
      when "RETURNED" then "售后"
      when "REJECTED" then "拒收"
      when "FROMWAREHOUSE" then "大库入"
    end
  end

  def order_price
    price
  end

  def order_payment
    order_price * num
  end

  def coupon_discount_fee
    if jingdong_trades
      if jingdong_trades.coupon_details.present?
        discount_fee = jingdong_trades.coupon_details.where(oid: oid).sum(:coupon_price)
      end
    end
    discount_fee ||  0
  end

end
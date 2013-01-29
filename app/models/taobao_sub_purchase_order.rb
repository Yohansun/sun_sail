# -*- encoding:utf-8 -*-

class TaobaoSubPurchaseOrder < Order
  field :status, type: String
  field :refund_fee, type: Float
  # field :id, type: Integer
  field :fenxiao_id, type: Integer
  field :tc_order_id, type: Integer
  field :order_200_status, type: String
  field :auction_price, type: Float
  field :old_sku_properties, type: String
  field :item_id, type: Integer
  field :item_outer_id, type: String
  field :sku_outer_id, type: String
  field :sku_properties, type: String
  field :num, type: Integer
  field :title, type: String
  field :price, type: Float
  field :snapshot_url, type: String
  field :created, type: DateTime
  field :total_fee, type: Float
  field :distributor_payment, type: Float
  field :buyer_payment, type: Float

  embedded_in :taobao_purchase_order

  def outer_iid
    item_outer_id
  end

  def sku_properties

  end  

  def product
    super(outer_iid)
  end

  def bill_info
    tmp = {}
    color_num.each do |nums|
      next if nums.blank?

      num = nums[0]
      next if num.blank?

      if tmp.has_key? num
        tmp["#{num}"][0] += 1
      else
        tmp["#{num}"] = [1, Color.find_by_num(num).try(:name)]
      end
    end

    [{
      iid: '',
      number: 1,
      storage_num: '',
      title: title,
      colors: tmp
    }]
  end

  def refund_status_text
    case self.status
      when "TRADE_REFUNDED" then "已退款"
      when "TRADE_REFUNDING" then "退款中"
    end
  end
end

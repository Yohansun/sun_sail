# -*- encoding:utf-8 -*-

class TaobaoOrder < Order

  include Mongoid::History::Trackable

  field :oid, type: String
  field :status, type: String

  field :outer_id, type: String
  field :outer_iid, type: String
  field :num_iid, type: String

  field :sku_id, type: String

  field :outer_sku_id, type: String
  field :sku_properties_name, type: String
  field :title, type: String
  field :price, type: Float, default: 0.0
  field :num, type: Integer
  field :total_fee, type: Float, default: 0.0
  field :payment, type: Float, default: 0.0
  field :discount_fee, type: Float, default: 0.0
  field :adjust_fee, type: Float

  field :item_meal_id, type: String
  field :item_meal_name, type: String
  field :modified, type: DateTime
  field :refund_id, type: String
  field :is_oversold, type: Boolean
  field :is_service_order, type: Boolean
  field :end_time, type: DateTime
  field :pic_path, type: String
  field :seller_nick, type: String
  field :buyer_nick, type: String
  field :snapshot_url, type: String
  field :snapshot, type: String
  field :timeout_action_time, type: DateTime
  field :buyer_rate, type: Boolean
  field :seller_rate, type: Boolean
  field :seller_type, type: String
  field :cid, type: Integer

  embedded_in :taobao_trades
  embedded_in :custom_trades
  embedded_in :trades

  track_history  :scope          => :taobao_trade,
                 :version_field  => :version,
                 :track_update   => true,
                 :track_create   => true

  def trade
    taobao_trades || custom_trades || trades
  end

  def item_outer_id
    outer_iid
  end

  def fetch_refund_price
    if refund_status == "SUCCESS"
      data = {trade: trade.attributes, parameters: {method: 'taobao.refund.get',fields: "refund_fee",refund_id: refund_id},trade_source_id: trade.trade_source_id}
      response = TaobaoQuery.get(data[:parameters],trade.trade_source_id)
      result = cache_exception(message: "淘宝退款金额抓取异常(#{trade.shop_name})",data: data.merge(response: response)) do
        response["refund_get_response"]["refund"]["refund_fee"].to_f
      end
      result.is_a?(Exception) ? 0 : result
    else
      0
    end
  end

  def sku_properties
    sku_properties_name
  end

  def taobao_sku
    scoped = TaobaoSku.where(account_id: account_id)
    if sku_id.present?
      scoped.find_by_sku_id(sku_id)
    else
      scoped.find_by_num_iid(num_iid)
    end
  end

  def sku_bindings
    taobao_sku.sku_bindings rescue []
  end

  def skus
    (taobao_sku && taobao_sku.skus.present? && taobao_sku.skus) || local_skus || []
  end

  def sku_products
    products = []
    if self.sku_bindings.present?
      self.sku_bindings.each do |binding|
        sku_id = binding.sku_id
        sku = Sku.find_by_id(sku_id)
        product = sku.try(:product)
        products << {sku_id: sku_id, number: binding.number, product: product} if product.present?
      end
    elsif self.local_skus.present?
      self.local_skus.each do |sku|
        sku_id = sku.id
        sku = Sku.find_by_id(sku_id)
        product = sku.try(:product)
        products << {sku_id: sku_id, number: 1, product: product} if product.present?
      end
    end
    products
  end

  def bill_info
    [{
      outer_id: '',
      number: 1,
      storage_num: '',
      title: title,
      colors: []
    }]
  end

  def refund_status_text
    case self.refund_status
      when "WAIT_SELLER_AGREE" then "买家已经申请退款，等待卖家同意"
      when "SELLER_REFUSE_BUYER" then "卖家拒绝退款"
      when "WAIT_BUYER_RETURN_GOODS" then "卖家已经同意退款，等待买家退货"
      when "WAIT_SELLER_CONFIRM_GOODS" then "买家已经退货，等待卖家确认收货"
      when "CLOSED" then "退款关闭"
      when "SUCCESS" then "退款成功"
    end
  end

  def order_price
    order_payment / num
  end

  def order_payment
    if taobao_trades
      if taobao_trades.orders.count == 1
        fee = payment - taobao_trades.post_fee
      else
        fee = payment
      end
    elsif custom_trades
      fee = payment
    elsif trades
      fee = payment
    end
    fee
  end

  def promotion_discount_fee
    if taobao_trades
      if taobao_trades.promotion_details.present?
        discount_fee = taobao_trades.promotion_details.where(oid: oid).sum(:discount_fee)
      end
    end
    discount_fee ||  0
  end

  def multi_product_properties
    mutiple_properties = []
    self.sku_products.each do |sku_product|
      category_properties = sku_product[:product].try(:category).try(:category_properties)
      next if category_properties.blank?
      (sku_product[:number]*self.num).times do |t|
        property_infos = {
          name: sku_product[:product].name,
          stock_in_bill_tid: trade_property_memos[t].try(:stock_in_bill_tid),
          local_outer_id: sku_product[:product].outer_id,
          "properties" => []
        }
        category_properties.each_with_index do |category_property, i|
          property_infos["properties"][i] = {
            name: category_property.name,
            type: "#{category_property.value_type_name}"
          }
          property_infos["properties"][i]['property_values'] = []
          category_property.values.each_with_index do |category_property_value, j|
            property_infos["properties"][i]['property_values'][j] = {}
            matched_property_value = trade_property_memos[t].property_values.where(category_property_value_id: category_property_value.id).first rescue nil
            property_infos["properties"][i]['property_values'][j]["id"] = category_property_value.id
            if matched_property_value.present?
              property_infos["properties"][i]['property_values'][j]["marked"] = true
              property_infos["properties"][i]['property_values'][j]['value'] = matched_property_value.value
            else
              property_infos["properties"][i]['property_values'][j]["marked"] = false
              property_infos["properties"][i]['property_values'][j]['value'] = category_property_value.value
            end
          end
        end
        mutiple_properties << property_infos
      end
    end if self.sku_products.present?
    mutiple_properties
  end
end

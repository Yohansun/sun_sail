# -*- encoding : utf-8 -*-
module MagicGift

  def add_gift_orders(trade, params)
    if params['is_split'] && params['is_split'] != "false"
      gift_trade = CustomTrade.create!(fields_for_gift_trade(trade))
    else
      gift_trade = trade
    end

    params['gift_orders'].each do |key, value|
      order = add_gift_order(gift_trade, value)
    end
  end

  def add_gift_order(trade, value)
    local_sku_id = (value['sku_id'].to_i == 0 ? nil : value['sku_id'].to_i)
    sku = trade.fetch_account.skus.find_by_id(local_sku_id)
    gift_product = trade.fetch_account.products.find_by_id(value['product_id'].to_i)
    trade.orders.create!(
      _type:          "TaobaoOrder",
      status:         "WAIT_SELLER_SEND_GOODS",
      refund_status:  "NO_REFUND",
      oid:            generate_gift_oid(trade),
      title:          value['gift_title'].try(:gsub, '标准款', ''),
      num:            value['num'].to_i,
      order_gift_tid: generate_gift_oid(trade),
      price:          0,
      total_fee:      0,
      payment:        0,
      discount_fee:   0,
      adjust_fee:     0,
      sku_id:         sku.try(:sku_id),  # this should be skus.sku_id not skus.id, and its' type is string not integer.
      local_sku_id:   local_sku_id, # this should be skus.id, and its' type is integer.
      pic_path:       gift_product.pic_url,
      cid:            gift_product.cid,
      outer_iid:      gift_product.outer_id,
      num_iid:        gift_product.num_iid
    )
  end

  def delete_gift_orders(trade, order_ids)
    order_ids.each do |order_id|
      gift_orders(trade).each do |gift_order|
        if gift_order.id.to_s == order_id
          if gift_order.trade.main_trade_id == trade.id.to_s && gift_order.trade.orders.count == 1
            gift_order.trade.delete!
          else
            gift_order.trade.orders.where(id: order_id).delete
          end
        end
      end
    end
  end

  def fields_for_gift_trade(trade)
    fields = {}
    fields['tid']                 = generate_gift_tid(trade)
    fields["main_trade_id"]       = trade.id
    fields["seller_nick"]         = trade.seller_nick
    fields["buyer_nick"]          = trade.buyer_nick
    fields["account_id"]          = trade.account_id
    fields["trade_source_id"]     = trade.trade_source_id
    fields["receiver_name"]       = trade.receiver_name
    fields["receiver_mobile"]     = trade.receiver_mobile
    fields["receiver_phone"]      = trade.receiver_phone
    fields["receiver_address"]    = trade.receiver_address
    fields["receiver_zip"]        = trade.receiver_zip
    fields["receiver_state"]      = trade.receiver_state
    fields["receiver_city"]       = trade.receiver_city
    fields["receiver_district"]   = trade.receiver_district
    fields["status"]              = 'WAIT_SELLER_SEND_GOODS'
    fields["created"]             = Time.now
    fields["pay_time"]            = Time.now
    fields["custom_type"]         = "gift_trade"

    fields
  end

  def gift_orders(trade)
    g_orders = []
    g_orders << trade.orders.where(:order_gift_tid.ne => nil)
    trade.fetch_account.trades.where(main_trade_id: trade.id.to_s).each do |gift_trade|
      g_orders << gift_trade.orders
    end
    g_orders.flatten
  end

  def generate_gift_tid(trade)
    trade.tid + "G" + (gift_orders(trade).count+1).to_s
  end

  def generate_gift_oid(trade)
    oid = trade.orders.map(&:order_gift_tid).compact.sort.last
    return oid.succ if oid
    trade.tid + "O" + (trade.orders.count+1).to_s
  end
end

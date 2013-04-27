# -*- encoding:utf-8 -*-
module TradesHelper
  def get_package(order, time)
    tmp = []
    order.sku_bindings.each do |binding|
      sku = Sku.find_by_id(binding.sku_id)
      product = sku.product
      number = binding.number
      tmp << {
        name: product.name,
        number: number
      }
    end
    tmp
  end

  def can_change_logistic(trade)
    trade.status == 'WAIT_SELLER_SEND_GOODS'
  end
end
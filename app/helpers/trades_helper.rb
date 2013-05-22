# -*- encoding:utf-8 -*-
module TradesHelper
  def get_package(order, time)
    tmp = []
    order.sku_bindings.each do |binding|
      sku = Sku.find_by_id(binding.sku_id)
      next unless sku
      product = sku.product
      next unless product
      number = binding.number
      tmp << {
        name: product.name,
        number: number,
        sku_id: binding.sku_id,
        sku_title: sku.title
      }
    end
    tmp
  end

  def can_change_logistic(trade)
    trade.status == 'WAIT_SELLER_SEND_GOODS'
  end
end
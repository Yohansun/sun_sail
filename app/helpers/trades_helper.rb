# -*- encoding:utf-8 -*-
module TradesHelper
  def get_package(outer_id, time)
    tmp = []

    iid_map = {
      'ICI0007' => '五合一配套抗碱底漆',
      'ICI0042' => '多乐士全效净味底漆',
      'ICI0043' => '多乐士全效净味底漆',
      'ICI0044' => '五合一配套抗碱底漆',
      'ICI0045' => '多乐士全效净味底漆',
      'ICI0046' => '多乐士全效净味底漆',
      'ICI0054' => '五合一配套抗碱底漆'
    }

    product = Product.where(outer_id: outer_id).first

    return tmp unless product
    product.packages.each do |p|
      item = Product.find_by_outer_id p.outer_id
      next unless item
      if time < '2012-10-22 00:00:00' && iid_map.keys.include?(product.outer_id) && item.name == '多乐士净味底漆'
        item_name = iid_map["#{product.outer_id}"]
      else
        item_name = item.name
      end

      tmp << {
        name: item_name,
        number: p.number
      }
    end

    tmp
  end

  def can_change_logistic(trade)
    trade.status == 'WAIT_SELLER_SEND_GOODS'
  end
end

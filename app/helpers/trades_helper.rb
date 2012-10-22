# -*- encoding:utf-8 -*-
module TradesHelper
  def get_package(iid,trade_id)
    trade = Trade.find trade_id
    tmp = []

    return tmp unless trade

    iid_map = {
      'ICI0007' => '五合一配套抗碱底漆',
      'ICI0042' => '多乐士全效净味底漆',
      'ICI0043' => '多乐士全效净味底漆',
      'ICI0044' => '五合一配套抗碱底漆',
      'ICI0045' => '多乐士全效净味底漆',
      'ICI0046' => '多乐士全效净味底漆',
      'ICI0054' => '五合一配套抗碱底漆'
    }

    product = Product.where(iid: iid).first
    return tmp unless product
    product.children.each do |p|
      if trade.created_at < '2012-10-22 00:00:00' && iid_map.keys.include?(product.iid) && p.name == '多乐士净味底漆'
        tmp << iid_map["#{product.iid}"]
      else
        tmp << p.name
      end
    end

    tmp
  end
end

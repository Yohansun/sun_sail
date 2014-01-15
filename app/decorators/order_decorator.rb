class OrderDecorator < Draper::Base
  decorates :order

  def item_id
    case order._type
    when 'TaobaoSubPurchaseOrder'
      order.item_id
    when 'TaobaoOrder','JingdongOrder','YihaodianOrder'
      order.oid
    end
  end

  def sku_properties
    case order._type
    when 'TaobaoSubPurchaseOrder'
      order.sku_properties
    when 'TaobaoOrder'
      order.sku_properties_name
    when 'JingdongOrder'
      ''
    when 'YihaodianOrder'
      ''
    end
  end

  def item_outer_id
    case order._type
    when 'TaobaoSubPurchaseOrder'
      order.item_outer_id
    when 'TaobaoOrder'
      order.outer_iid
    when 'JingdongOrder'
      order.num_iid
    when 'YihaodianOrder'
      order.num_iid
    end
  end

  def title
    case order._type
    when 'TaobaoSubPurchaseOrder'
      order.title
    when 'TaobaoOrder','JingdongOrder','YihaodianOrder'
      order.title
    end
  end

  def price
    case order._type
    when 'TaobaoSubPurchaseOrder'
      order.auction_price
    when 'TaobaoOrder','JingdongOrder','YihaodianOrder'
      order.price
    end
  end

end

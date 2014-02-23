# -*- encoding : utf-8 -*-

desc "添加奔跑的南瓜王店铺演示数据"
task :generate_data_for_presentation => :environment do

p "修改账户名称"
  account = Account.find_by_name("奔跑的南瓜王")
  account.update_attributes(name: "科勒旗舰店")

p "新建淘宝商品"
  TaobaoProductData = [
    {name: "【科勒Kohler旗舰店】索尚铸铁浴缸K-941T", outer_id: "K-941T", cat_name: "浴缸"},
    {name: "【科勒旗舰店】皮诺五级旋风分体座便器 K-3831T-0", outer_id: "K-3831T-0", cat_name: "座便器"},
    {name: "【科勒Kohler旗舰店】丽笙单把脸盆龙头 K-12050T-CP", outer_id: "K-12050T-CP", cat_name: "龙头"}
  ]

  3.times do |i|
    taobao_product = TaobaoProduct.create(
      category_id: nil,
      account_id: account.id,
      num_iid: Time.now.to_i + rand(100..200),
      price: 200+i,
      outer_id: TaobaoProductData[i][:outer_id],
      cat_name: TaobaoProductData[i][:cat_name],
      name: TaobaoProductData[i][:name],
    )

    taobao_product.taobao_skus.create(
      account_id: account.id,
      num_iid: taobao_product.num_iid
    )
  end

p "新建本地商品"
  ProductData = [
     {name: "索尚铸铁浴缸", outer_id: "K-941T", cat_name: "浴缸"},
     {name: "皮诺五级旋风分体座便器", outer_id: "K-3831T-0", cat_name: "座便器"},
     {name: "丽笙单把脸盆龙头", outer_id: "K-12050T-CP", cat_name: "龙头"}
  ]

  3.times do |i|
    product = Product.create(
      category_id: nil,
      account_id: account.id,
      num_iid: account.taobao_products.find_by_outer_id(ProductData[i][:outer_id]).num_iid,
      price: 200+i,
      outer_id: ProductData[i][:outer_id],
      cat_name: ProductData[i][:cat_name],
      name: ProductData[i][:name],
      storage_num: "",
      on_sale: true
    )

    product.skus.create(
      num_iid: product.num_iid,
      account_id: account.id
    )
  end

p "绑定Sku"
  account.taobao_skus.each do |taobao_sku|
    taobao_sku.sku_bindings.create(
      number: 1,
      sku_id: Sku.find_by_num_iid(taobao_sku.num_iid).id
    )
  end

p "添加库存"
  account.sellers.find_each do |seller|
    account.skus.each do |sku|
      account.stock_products.create(
        max: 999999,
        safe_value: 0,
        activity: 500,
        actual: 500,
        product_id: sku.product_id,
        seller_id: seller.id,
        sku_id: sku.id,
        num_iid: sku.product.num_iid
      )
    end
  end

p "新建测试流程订单，报表相关订单"

  adapt_order = Proc.new{|trade, outer_id, num=1, order_num=0|
    trade.taobao_orders[order_num].update_attributes(
    outer_iid: outer_id,
    num_iid: account.taobao_products.find_by_outer_id(outer_id).num_iid,
    title: account.taobao_products.find_by_outer_id(outer_id).name,
    num: num,
    price: account.taobao_products.find_by_outer_id(outer_id).price,
    payment: account.taobao_products.find_by_outer_id(outer_id).price
  )}

  p "--正常业务流"

  trade = Fabricate(:taobao_trade, account_id: account.id)
  trade.update_attributes(
    receiver_state: "浙江省",
    receiver_city: "温州市",
    receiver_district: "瓯海区"
  )

  adapt_order.call(trade, "K-941T", 2)

  p "--可合并订单"

  mergeable_id = nil
  2.times do |i|
    trade = Fabricate(:taobao_trade, account_id: account.id)
    trade.update_attributes(
      receiver_state: "浙江省",
      receiver_city: "宁波市",
      receiver_district: "鄞州区",
      receiver_address: "聚才路966号  水木清华A区 13幢203室",
      receiver_name: "高敏",
      receiver_mobile: "1393454567",
      buyer_nick: "fadfa3242",
      mergeable_id: mergeable_id.present? ? mergeable_id : trade.id
    )
    if mergeable_id.present?
      adapt_order.call(trade, "K-12050T-CP")
    else
      mergeable_id = trade.id
      adapt_order.call(trade, "K-3831T-0")
    end
  end

  p "--可拆分订单"

  trade = Fabricate(:taobao_trade, account_id: account.id)
  trade.update_attributes(
    receiver_state: "北京",
    receiver_city: "北京市",
    receiver_district: "丰台区"
  )

  trade.taobao_orders << Fabricate.build(:taobao_order)

  adapt_order.call(trade, "K-3831T-0", 2, 0)
  adapt_order.call(trade, "K-12050T-CP", 3, 1)

  p "--退款订单"

  trade = Fabricate(:taobao_trade, account_id: account.id)
  trade.update_attributes(
    receiver_state: "江苏省",
    receiver_city: "苏州市",
    receiver_district: "张家港市"
  )

  trade.taobao_orders << Fabricate.build(:taobao_order)

  adapt_order.call(trade, "K-3831T-0", 2, 0)
  adapt_order.call(trade, "K-12050T-CP", 3, 1)

  trade.update_attributes(has_refund_orders: true)
  trade.taobao_orders.last.update_attributes(refund_status: "WAIT_SELLER_AGREE")

  trade.unusual_states.create(
    reason: "买家要求退款",
    key: "buyer_demand_refund",
    reporter: "系统预警",
    reporter_role: "magic_system",
    created_at: Time.now
  )

  p "--生成100个交易成功订单"

  outer_ids = ["K-3831T-0", "K-12050T-CP", "K-941T"]
  areas = [
    ["北京", "北京市", "朝阳区"],
    ["上海", "上海市", "青浦区"],
    ["浙江省","温州市","瓯海区"]
  ]
  sellers = account.sellers.collect{|seller| [seller.id, seller.name]}
  seller_count = sellers.count.zero? ? 0 : (sellers.count - 1)
  if sellers != []
    100.times do |i|
      trade = Fabricate(:taobao_trade, account_id: account.id)
      area = areas[rand(0..2)]
      seller = sellers[rand(0..seller_count)]
      trade.update_attributes(
        receiver_state: area[0],
        receiver_city: area[1],
        receiver_district: area[2],
        seller_id: seller[0],
        seller_name: seller[1],
        status: "TRADE_FINISHED",
        dipatched_at: Time.now,
        delivered_at: Time.now,
        end_time: Time.now
      )

      adapt_order.call(trade, outer_ids[rand(0..2)], rand(1..3))
    end
  end
end
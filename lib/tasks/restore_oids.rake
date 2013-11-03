# -*- encoding:utf-8 -*-

desc "修复淘宝订单oid"
task :restore_oids => :environment do
  #### 本次修改不恢复合并订单和人工订单 ####

  #修复淘宝子订单oid
  start_time = Time.now.beginning_of_year
  end_time = '2013-09-24 23:59:59'.to_time(:local)
  trades = Trade.where(:trade_gifts.nin => [nil,[]]).between(created_at: start_time..end_time).where(_type: "TaobaoTrade")

  trades.each do |trade|
    response = TaobaoQuery.get({
            method: 'taobao.trade.fullinfo.get',
            fields: 'orders',
            tid: "#{trade.tid}"}, trade.fetch_account.trade_sources.where(trade_type: "Taobao").first.id
            )
    if response['trade_fullinfo_get_response']
      fetched_orders = response['trade_fullinfo_get_response']['trade']['orders']['order']
      fetched_orders.each do |forder|
        native_order = trade.taobao_orders.where(num_iid: forder['num_iid'], order_gift_tid: nil).first
        if native_order
          native_order.update_attributes(oid: forder['oid'])
        else
          p "--TaobaoTrade: #{trade.tid}--TaobaoOrder: #{forder['num_iid']}--no native order found !!!"
        end
      end
    end
  end

  #将赠品子订单oid改为order_gift_tid
  trades = Trade.where(:trade_gifts.nin => [nil,[]])
  trades.each do |trade|
    trade.orders.where(:order_gift_tid.ne => nil).each do |gift_order|
      gift_order.update_attributes(oid: gift_order.order_gift_tid)
    end
  end
end
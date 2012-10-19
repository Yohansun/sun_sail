# -*- encoding : utf-8 -*-
class DuluxOrdertracePush
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao
  
  def perform(tid)
    
    code = false
    
    #dummy send #调用该接口可实现无需物流（虚拟）发货,使用该接口发货，交易订单状态会直接变成卖家已发货
    # code = false
    # trade = TaobaoTrade.where(tid: tid).first
    # dummy_send_response = TaobaoQuery.get({
    #   method: 'taobao.logistics.dummy.send',
    #   tid: tid
    #   }, trade.try(:trade_source_id)
    # )
    # p dummy_send_response
    
    # if dummy_send_response['delivery_dummy_send_response']
    #   p "start dummy send"
    #   p response['shipping']['is_success']
    # end
    
    # 自有物流发货
    send_response = TaobaoQuery.get({
      method: 'taobao.logistics.offline.send',
      tid: trade.tid,
      out_sid: '762016565903',
      company_code: '自有物流'}, trade.try(:trade_source_id)
    )
    
    p send_response
    
    #push trace
    response = TaobaoQuery.get({
      method: 'taobao.logistics.ordertrace.push',
      mail_no: '762016565903',                         #快递单号        
      occure_time: Time.now.strftime("%Y-%m-%d %H:%M:%S"),                    #流转节点发生时间
      operate_detail: '浙江省杭州市西湖区上车扫描',                 #流转节点的详细地址及操作描述
      company_name:  '自有物流'                    #物流公司名称
      # operator_name:,                 #快递业务员名称
      # operator_contact:,              #快递业务员联系方式，手机号码或电话。
      # current_city:,                  #流转节点的当前城市
      # next_city:,                     #流转节点的下一个城市
      # facility_name:,                 #网点名称 
      # node_description:               #描述当前节点的操作，操作是“揽收”、“派送”或“签收”。
      }, trade.try(:trade_source_id)
    )
    
    p response

    if response['logistics_ordertrace_push_response']
      code = response['logistics_ordertrace_push_response']['shipping']['is_success']
    end
    
    if code
      #TODO
    end
    
  end
  
end

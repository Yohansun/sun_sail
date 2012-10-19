# -*- encoding : utf-8 -*-
class DuluxOrdertracePush
  include Sidekiq::Worker
  sidekiq_options :queue => :taobao
  
  def perform(tid)
    code = false
    trade = TaobaoTrade.where(tid: tid).first
    response = TaobaoQuery.get({
      method: 'taobao.logistics.ordertrace.push',
      mail_no: '762016565903',                         #快递单号        
      occure_time: Time.now,                    #流转节点发生时间
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
      response = response['shipping']['is_success']
      is_succsess = response['is_succsess']
    end
    
    if code
      #TODO
    end
    
  end
  
end

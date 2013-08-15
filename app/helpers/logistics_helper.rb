#encoding: utf-8
require 'hashie'
# How to use
# Logistic.all.collect {|x| [x.name,get_logistic_id(trade._type,x.name)]}
# 注意验证logistic_id不能为空
module LogisticsHelper

  def get_logistic_id(source_type,name)
    cache = ActiveSupport::Cache::MemoryStore.new(:expires_in => 1.hour)
    source_name = source_type.underscore.gsub(/trade$/,'source')
    source_id = current_account.send(source_name).id
    cache.fetch("#{source_type}_#{source_id}_#{name}") do
      case source_type
      when "TaobaoTrade"    then get_taobao_logistic(name).id rescue nil
      when "YihaodianTrade" then get_yihaodian_logistic(name).id rescue nil
      when "JingdongTrade"  then get_jingdong_logistic(name).logistics_id rescue nil
      end
    end
  end

  def get_taobao_logistic(name)
    response = TaobaoQuery.get({method: "taobao.logistics.companies.get", fields: 'id,code,name,reg_mail_no'},current_account.taobao_source.id)
    logistics_company = response["logistics_companies_get_response"]["logistics_companies"]["logistics_company"]
    Hashie::Mash.new logistics_company.find {|u| u["name"] =~ /^#{name.to(1)}}/}
  end

  def get_yihaodian_logistic(name)
    api_paramters = current_account.yihaodian_query_conditions
    response = YihaodianQuery.post({method: 'yhd.logistics.deliverys.company.get'},api_paramters)
    logistics_info = response["response"]["logisticsInfoList"]["logisticsInfo"]
    Hashie::Mash.new logistics_info.find {|u| u["companyName"] =~ /^#{name.to(1)}}/}
  end

  def get_jingdong_logistic(name)
    api_paramters = current_account.jingdong_query_conditions
    response = JingdongQuery.get({method: '360buy.delivery.logistics.get'},api_paramters)
    logistics_list = response["delivery_logistics_get_response"]["logistics_companies"]["logistics_list"]
    Hashie::Mash.new logistics_list.find {|u| u["logistics_name"] =~ /^#{name.to(1)}}/}
  end
end

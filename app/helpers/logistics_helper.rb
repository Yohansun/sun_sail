#encoding: utf-8
require 'hashie'
# How to use
# Logistic.all.collect {|x| [x.name,get_logistic_id(trade._type,x.name)]}
# 注意验证logistic_id不能为空
module LogisticsHelper

  def get_logistic_id(source_type,name)

    source_name = source_type.underscore.gsub(/trade$/,'source')
    source_id = current_account.send(source_name).try(:id)
    cache_name = "#{source_type}:#{source_id}"
    cache(:expires_in => 1.hour).fetch("#{cache_name}_#{name}}") do
      case source_type
      when "TaobaoTrade"    then get_taobao_logistic(name,cache_name).id rescue nil
      when "YihaodianTrade" then get_yihaodian_logistic(name,cache_name).id rescue nil
      when "JingdongTrade"  then get_jingdong_logistic(name,cache_name).logistics_id rescue nil
      end
    end
  end

  private
  def get_taobao_logistic(name,cache_name=nil)
    response = cache(:expires_in => 1.hour).fetch(cache_name+"_taobao") do
      TaobaoQuery.get({method: "taobao.logistics.companies.get", fields: 'id,code,name,reg_mail_no'},current_account.taobao_source.id)
    end

    logistics_company = response["logistics_companies_get_response"]["logistics_companies"]["logistics_company"]
    Hashie::Mash.new logistics_company.find {|u| u["name"] =~ /^#{name.to(1)}}/}
  end

  def get_yihaodian_logistic(name,cache_name=nil)
    api_paramters = current_account.yihaodian_query_conditions

    response = cache(:expires_in => 1.hour).fetch(cache_name+"_yihaodian") do
      YihaodianQuery.post({method: 'yhd.logistics.deliverys.company.get'},api_paramters)
    end

    logistics_info = response["response"]["logisticsInfoList"]["logisticsInfo"]
    Hashie::Mash.new logistics_info.find {|u| u["companyName"] =~ /^#{name.to(1)}}/}
  end

  def get_jingdong_logistic(name,cache_name=nil)
    api_paramters = current_account.jingdong_query_conditions

    response = cache(:expires_in => 1.hour).fetch(cache_name+"_jingdong") do
      JingdongQuery.get({method: '360buy.delivery.logistics.get'},api_paramters)
    end

    logistics_list = response["delivery_logistics_get_response"]["logistics_companies"]["logistics_list"]
    Hashie::Mash.new logistics_list.find {|u| u["logistics_name"] =~ /^#{name.to(1)}}/}
  end

  def cache(options={})
    ActiveSupport::Cache::MemoryStore.new(options)
  end
end
#encoding: utf-8
#一号店普通产品
class YihaodianGeneralProductSync < ECommerce::Synchronization::Base
  set_klass "YihaodianProduct"
  identifier 'product_id'
  set_variable :api, "yhd.general.products.search"
  set_variable :get_size, 100
  set_variable :page_no, 1
  set_variable :page_count, proc { |v|  total_results.zero? ? 1 : (total_results / get_size.to_f).ceil}

  def initialize(trade_source_id)
    @trade_source = TradeSource.find(trade_source_id)
    @default_attributes = {account_id: @trade_source.account_id,genre: 0,trade_source_id: trade_source_id,shop_name: @trade_source.name}
    @query_condition = @trade_source.yihaodian_query_conditions
    super
  end

  def response
    params = {method: api,verifyFlg: 2, pageRows: get_size, curPage: page_no}
    @response = YihaodianQuery.post(params,@query_condition)
    datas = {api_results: @response,api_parameters: params,:trade_source => @trade_source,:result => []}
    handle_exception(datas) do
      except_error = @response["response"]["errInfoList"]["errDetailInfo"].all? {|u| u["errorCode"] == 'yhd.combine.products.search.prod_not_found'} rescue false
      return [] if except_error
      @response["response"]["productList"]["product"].each {|hash| hash.underscore_key!}
    end
  end

  def total_results
    @total_results ||= @response["response"]["totalCount"]
  end

  def parsing
    @general_product_ids ||= []
    (@general_product_ids += super.collect{|u| u["product_id"]}) && (@page_no += 1) while page_no <= page_count
  end
end

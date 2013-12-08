#encoding: utf-8
# 如果方法中可能会出现非正常的 返回数据(你觉得可能会发生的,会导致程序或数据出现问题的地方)可使用此方法.
# cache_exception  只发送错误邮件,忽略传递的block中的异常.
# cache_exception! 发送错误邮件, 如果传递的block中有异常发生, 抛出异常.
module Kernel
  # Options:
  #  [:message] 报错的邮件主题(必填)
  #  [:data]    导致出错的原始参数,可能是方法的参数,只要是能帮助你快速定位问题的相关参数(必填!!!!!!,
  #             而且最好请按照以下的方式,  这样可以方便的排错)
  #
  #  比如 response = TaobaoQuery.get({method: 'taobao.trades.sold.get',fields: 'total_fee',type: 'fixed',
  #      start_created: '2012-11-11 11:11:11,end_created: "2012-12-12 12:12:12",page_no: 1,page_size: 100},trade_source_id)
  #
  #  建议这么写:
  #
  #  parameters = {parameters: {method: 'taobao.trades.sold.get',fields: 'total_fee',type: 'fixed',
  #  start_created: '2012-11-11 11:11:11,end_created: "2012-12-12 12:12:12",page_no: 1,page_size: 100}}  
  #
  #  response = TaobaoQuery.get(parameters,trade_source_id)
  #  
  #  data = {parameters: parameters,response: response}
  #
  # cache_exception!(message: "淘宝订单抓取异常(xxx旗舰店)",data: data.merge(trade_source_id: trade.trade_source_id)) do
  #   # 在此不用考虑是否为nil, 因为如果为nil的话说明可能api调用有问题,需要抛出异常.
  #   # 在此例子中你需要做的是正常的处理流程,不需要关心返回的结果正不正确
  #   response['trades_sold_get_response']['trades']['trade'].each {|trade| build(trade)}
  # end
  #
  # def build(trade)
  #   # ...
  # end
  def cache_exception(options={},&block)
    raise TypeError, "参数类型必须是 Hash " if !options.is_a?(Hash)
    options.symbolize_keys!
    message ,data = options[:message], options[:data]
    data = [data] if !options[:data].respond_to?(:each)
    raise ":message,:data 参数不能为空" if !(message && data)
    exception = yield rescue $! if block_given?
    BacktraceMailer.background_exception_notification(exception,data: data,message: message) if exception.is_a?(Exception)
    exception
  end

  # 发送错误邮件, 如果传递的block中有异常发生, 抛出异常.
  def cache_exception!(options={},&block)
    exception = cache_exception(options,&block)
    raise exception if exception.is_a?(Exception)
  end
end
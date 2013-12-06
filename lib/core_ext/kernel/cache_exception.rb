#encoding: utf-8
module Kernel
  # 处理异常并继续运行当前程序
  # Options:
  #  [:message] 报错的邮件主题(必填)
  #  [:data]    变量是如何产生的数据源(必填!!!!!!,而且最好请按照以下的方式,  这样可以方便的排错)
  #  比如 response = TaobaoQuery.get({method: 'taobao.trades.sold.get',fields: 'total_fee',type: 'fixed',
  #      start_created: '2012-11-11 11:11:11,end_created: "2012-12-12 12:12:12",page_no: 1,page_size: 100},trade_source_id)
  #  建议这么写:
  #  parameters = {parameters: {method: 'taobao.trades.sold.get',fields: 'total_fee',type: 'fixed',
  #  start_created: '2012-11-11 11:11:11,end_created: "2012-12-12 12:12:12",page_no: 1,page_size: 100}}  
  #  TaobaoQuery.get(parameters,trade_source_id)
  #  
  #  data = {parameters: parameters,response: response}
  # cache_exception!(message: "订单抓取异常",data: data) do
  #   # 依赖请求正常的结果的 程序体
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

  # 强制抛异常,退出当前运行的方法
  def cache_exception!(options={},&block)
    exception = cache_exception(options,&block)
    raise exception if exception.is_a?(Exception)
  end
end
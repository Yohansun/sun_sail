#encoding: utf-8
class BaseSync
  class NotImplement < Exception; end
  attr_accessor :trade_source
  attr_accessor :options
  attr_accessor :query

  def initialize(trade_source_id,options={})
    @trade_source = TradeSource.find(trade_source_id)
    @options = default_options.merge(options)
  end

  def default_options
    {end_time: Time.now}
  end

  # 遍历请求API的每页的数据
  # each_page do |response|
  #   response['xxx']['...']..['xxx'].each do |item|
  #     create_or_update(item) # need define create_or_update method
  #   end
  # end
  def each_page(&block)
    data = query.dup.merge(response: response=fetch_data)
    cache_exception(message: options[:error_message] || "同步异常(#{trade_source.name})",data: data) do
      options[:total_page] ||= total_page.call(response)
      query[:page_no] += 1
      yield response
    end
    return if options[:total_page].to_i == 0

    each_page(&block) if query[:page_no] <= options[:total_page]
  end

  # 调用API,不做任何处理
  def fetch_data
    raise NotImplement
  end

  # 调用API的参数
  def query
    raise NotImplement
  end

  # API返回数据总的页数
  def total_page
    raise NotImplement
  end
end
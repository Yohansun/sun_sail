# -*- encoding : utf-8 -*-
class Gqs
  # 新建出库单
  def self.order_add(account, xml)
    base_uri = URI.encode "http://service.gqsscm.com/yh/GQSHandler.ashx"
    options = {:body => {brand: account.settings.gqs_brand_name, method: 'OrderAdd', content: xml}}
    response = HTTParty.post(base_uri, options).parsed_response.squish.force_encoding('utf-8')
  end

  # 新建入库单
  def self.receipt_add(account, xml)
    base_uri = URI.encode "http://service.gqsscm.com/yh/GQSHandler.ashx"
    options = {:body => {brand: account.settings.gqs_brand_name, method: 'ReceiptAdd', content: xml}}
    response = HTTParty.post(base_uri, options).parsed_response.squish.force_encoding('utf-8')
  end

  #查询当前库存(若希望请求一个或者多个产品的当前库存，则在请求内容中填写一个或者多个产品。若请求内容为空，则返回所有的产品库存)
  def self.inventory_query(account, item = nil)
   xml = "<DATA><RECORD><ITEMID>#{item}</ITEMID></RECORD></DATA>"
   base_uri = URI.encode "http://service.gqsscm.com/yh/GQSHandler.ashx"
   options = {:body => {brand: account.settings.gqs_brand_name, method: 'InvQuery', content: xml}}
   response = HTTParty.post(base_uri, options).parsed_response.squish.force_encoding('utf-8')
   results = Hash.from_xml(response).as_json
   if results['DATA'] && results['DATA']['RECORD']
    records = results['DATA']['RECORD']
    records.each do |record|
      status = record['STATUS']
      # 1 可发 2 残疵 3 锁定 4 破损
      if status == "1"
        item_id = record['ITEMID']
        actual = record['QTYREAL']
        activity = record['QTYONHAND']
        Rails.logger.warn "#{item_id}------#{actual}------#{activity}"
      end
    end
   end
  end

  # 订单取消
  def self.cancel_order(account,options={})
    options.symbolize_keys!
    method , prefix = options.delete(:method),options.delete(:_prefix)
    raise "prefix can't be nil" if prefix.nil?
    raise "method can't be nil" if method.nil?

    xml = options.prefix_root(prefix).deep_transform_keys {|k,v|
      k.to_s.upcase
    }.to_xml(root: "DATA",skip_instruct: true)

    base_uri = URI.encode "http://service.gqsscm.com/yh/GQSHandler.ashx"
    options = {:body => {brand: account.settings.gqs_brand_name, method: method, content: xml}}
    response = HTTParty.post(base_uri, options).parsed_response.squish.force_encoding('utf-8')
  end

end

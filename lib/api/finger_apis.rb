#encoding: utf-8
module MagicOrder
  ### 此类用于api中的method自动查找对应的API
  # 比如 http://magic-solo.networking.io/api/v1?method=refund_product_operation&datas[id]=1&datas[refund_product_id]=1
  # 会对应到 http://magic-solo.networking.io/api/v1/warehouses/1/refund_products/1 请求中.
  module FingerApis
    include MagicOrders::Application.routes.url_helpers

    def self.api(name,&block)
      apis.merge!({name => block})
    end

    def self.apis
      @apis ||= {}
    end

    def api_path(attrs)
      attrs = attrs.dup
      data = Hashie::Mash.new(attrs)
      method_path = attrs["method"].to_sym rescue return
      api?(method_path) &&
      attrs[:path_info] + FingerApis.apis[method_path].call(data)
    end

    def api?(name)
      FingerApis.apis.key?(name.to_sym)
    end

    # TODO 填充url内容的逻辑应该放到这的 没找到比较折中的解决办法

    # 退货单确认
    api :"warehouse.refund_product_verify" do |params|
      "/refund_products/refund_product_verify"
    end

    #入库单确认
    api :"warehouse.stock_in_bill_verify" do |params|
      "/stock_in_bills/stock_in_bill_verify"
    end

    #出库单确认
    api :"warehouse.stock_out_bill_verify" do |params|
      "/stock_out_bills/stock_in_bill_verify"
    end
  end
end
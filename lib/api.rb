Dir["#{Rails.root}/lib/api/*.rb"].each {|file| require file}

module MagicOrder
  class API < Grape::API
    version 'v1', using: :param, parameter: "v"

    helpers APIHelpers
    include FingerApis
    before { authenticate! }

    formatter :xml, Proc.new {|obj|
      if (keys = obj.keys) && keys.length == 1
        obj[keys.first].to_xml :root => keys.first
      else
        obj.to_xml
      end
    }

    before do
      # 格式化url中传递的xml或json文本,填充到resetAPI对应的params中       #TODO 应该移到call里面
      datas = {datas: DataParse.new(env,current_account.name).parse}
      params.deep_merge!(datas)
      # 通过 uri中format字段控制返回的数据类型   http://magic-solo.networking.io/api/v1?format=xml
      set_content_type if headers['Content-Type'].blank? && !params[:format].nil?
    end

    # log/api.log
    use ApiLogger

    rescue_from ActiveRecord::RecordNotFound,Mongoid::Errors::DocumentNotFound do
      rack_response({'message' => '404 Not found'}.to_json, 404)
    end

    # 自动匹配url参数中的method到具体的路由请求中
    # http://magic-solo.networking.io/api/v1?method=refund_product_verify
    # 会自动分配到:
    # http://magic-solo.networking.io/api/v1/warehouses/warehouse_id/refund_products/refund_product_id
    def call(env)
      attrs = parameters(env)
      env["PATH_INFO"] = api_path(attrs) || env["PATH_INFO"]
      super
    end

    # 为url中method提供支持
    %w(get put delete post).each do |method|
      params do
        requires :method, type: String, desc: "API name", regexp: /^(#{FingerApis.apis.keys.join('|')})$/
        requires :format, type: String, desc: "format",regexp: /^(xml|json)$/
        requires :v,      type: String, desc: "API Version"
      end
      send(method) do
      end
    end

    # http://hostname/api/v1?method=refund_product_operation?format=json&private_token=abc&
    # datas[warehouse_id]=1&datas[refund_product_id]=2&datas[status]=confirm
    mount StockBill
    mount RefundProduct

    private
    def parameters(env)
      env["rack.request.form_hash"].merge(path_info(env)) rescue {}
    end

    def path_info(env)
      {path_info: env["PATH_INFO"]}
    end
  end
end
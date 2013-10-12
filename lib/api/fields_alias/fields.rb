module FieldsAlias
  module Fields
    module ClassMethods
      def api(name,options,&block)
        options = options.merge(block.call)
        apis << {name => options}
      end

      def namespace(name,&block)
        spaces << name.to_sym if !spaces.include?(name.to_sym)
        options = block.call name
      end

      def find(third_part,api)
        api = api.to_sym
        send(third_part).find {|x| x.key?(api)}[api]
      end

      def apis
        @apis ||= []
      end

      def spaces
        @spaces ||= []
      end

      def method_missing(method_id,args=[],&block)
        method = method_id.to_sym
        if api?(method)
          apis.find_all {|x| x.key?(method)}
        elsif third_part?(method)
          apis.find_all {|x| x.any?{|u,v| v[:_header] == method }}
        else
          super
        end
      end

      def respond_to?(method)
        api?(method) || third_part?(method) || super
      end

      def api?(method)
        apis.any? {|hash| hash.key?(method.to_sym)}
      end

      def third_part?(method)
        apis.any? {|x| x.any?{|u,v| v[:_header] == method.to_sym }}
      end
    end
    extend ClassMethods


    namespace :biaogan do |name|
      api :refund_product_verify,:_header => name do
        {
          :stock_out_bills  => {:from => 'outputBacks',:with => lambda { |value| Array.wrap(value["outputBack"]).collect {|x| FieldsAlias.third_part("biaogan","refund_product_verify").new x}  },:extract => true},
          :tid              => {:from => 'CustmorOrderNo',:extract => true},
          :received_time    => {:from => "ExpectedArriveTime"},
          :order_no         => {:from => "orderNo",:extract => true},
          :ship_no          => {:from => "shipNo"},
          :ship_time        => {:from => "shipTime"},
          :carrier_id       => {:from => "carrierID"},
          :carrier_name     => {:from => "carrierName"},
          :customer_id      => {:from => "customerId"},
          :bg_no            => {:from => "bgNo"},
          :skus             => {:from => "send"},
          :sku_code         => {:from => "skuCode"},
          :sku_num          => {:from => "skuNum"}
        }
      end
    end

    namespace :qos do |name|
      api :refund_product_verify,:_header => name do
        {
          :tid              => {:from => "ORDERID"},
          :logistic_code    => {:from => "OPTTYPE"},
          :order_type       => {:from => "OPTTYPE"},
          :logistic_waybill => {:from => "SHIPMENTID"}
        }
      end
    end
  end
end
# -*- encoding : utf-8 -*-
class Sms
  require "savon"
  require "collections"
  CLINET = Savon::Client.new("http://www.mdao.com/nippon/services/SMS?wsdl")
  
  attr_accessor :mobiles, :content

  def initialize(content, mobiles)
    @content = content
    @mobiles = mobiles
  end

  def transmit
    if Rails.env.production?
      response = CLINET.request(:batch_send) do
        soap.body = "<loginName>user01</loginName><loginPswd>123456</loginPswd><mobiles>18210355909</mobiles><content>#{self.content}</content><fixedTime></fixedTime><sendId></sendId><extid></extid>"
      end
      response.body[:batch_send_response][:out]
    else
      response = CLINET.request(:batch_send) do
        soap.body = "<loginName>user01</loginName><loginPswd>123456</loginPswd><mobiles>18911938790</mobiles><content>#{self.content}</content><fixedTime></fixedTime><sendId></sendId><extid></extid>"
      end
      response.body[:batch_send_response][:out]
    end
  end
end

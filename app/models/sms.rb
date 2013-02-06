# -*- encoding : utf-8 -*-
class Sms
  require "savon"
  require "collections"
  
  attr_accessor :account, :mobiles, :content

  def initialize(account, content, mobiles)
    @account = account
    @content = content
    @mobiles = mobiles
  end

  def transmit
    if @account.key == "dulux"
      http_transmit
    else
      soap_transmit
    end  
  end

  def self.receive
    if TradeSetting.company == "dulux"
      Sms.http_receive
    else
      Sms.soap_receive
    end  
  end
  
  def soap_transmit
    client = Savon::Client.new(@account.setting('sms_soap_gateway'))
    loginName = @account.setting('loginName')
    loginPswd = @account.setting('loginPswd')
    if Rails.env.production?
      response = client.request(:batch_send) do
        soap.body = "<loginName>#{loginName}</loginName><loginPswd>#{loginPswd}</loginPswd><mobiles>#{self.mobiles}</mobiles><content>#{self.content}</content><fixedTime></fixedTime><sendId></sendId><extid></extid>"
      end
      response.body[:batch_send_response][:out]
    else
      response = client.request(:batch_send) do
        soap.body = "<loginName>#{loginName}</loginName><loginPswd>#{loginPswd}</loginPswd><mobiles>#{@account.setting('sms_test_mobile')}</mobiles><content>#{self.content}</content><fixedTime></fixedTime><sendId></sendId><extid></extid>"
      end
      response.body[:batch_send_response][:out]
    end
  end  

  def self.soap_receive
  
  end  
  
  def http_transmit
    client = @account.setting('sms_http_gateway')
    mobiles = self.mobiles
    content = self.content.encode!('GBK')
    uid = @account.setting('sms_http_uid')
    pwd = @account.setting('sms_http_pwd')
    if Rails.env.production?
      request = "uid=#{uid}&pwd=#{pwd}&mobile=#{mobiles}&Msg=#{content}&spnum=0&OpType=0"
    else
      request = "uid=#{uid}&pwd=#{pwd}&mobile=#{@account.setting('sms_test_mobile')}&Msg=#{content}&spnum=0&OpType=0"
    end 
    full_resquest = URI.escape(client + request)
    send_request = HTTParty.get(full_resquest)
  end
  
  def self.http_receive
    client = TradeSetting.sms_http_receive_gateway
    uid = TradeSetting.sms_http_uid
    pwd = TradeSetting.sms_http_pwd
    request = "uid=#{TradeSetting.sms_http_uid}&pwd=#{TradeSetting.sms_http_pwd}"
    full_resquest = URI.escape(client + request)
    send_request = HTTParty.get(full_resquest)
  end

end

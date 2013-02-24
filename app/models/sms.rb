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
    if @account.key == "nippon"
      soap_transmit
    else
      http_transmit
    end
  end

  def self.receive(account_id)
    account = Account.find_by_id(account_id)
    if account.key == "nippon"
      Sms.soap_receive(account_id)
    else
      Sms.http_receive(account_id)
    end
  end

  def soap_transmit
    client = Savon::Client.new(@account.settings.sms_soap_gateway)
    loginName = @account.settings.loginName
    loginPswd = @account.settings.loginPswd
    mobiles = @account.settings.sms_test_mobile
    if Rails.env.production?
      response = client.request(:batch_send) do
        soap.body = "<loginName>#{loginName}</loginName><loginPswd>#{loginPswd}</loginPswd><mobiles>#{self.mobiles}</mobiles><content>#{self.content}</content><fixedTime></fixedTime><sendId></sendId><extid></extid>"
      end
      response.body[:batch_send_response][:out]
    else
      response = client.request(:batch_send) do
        soap.body = "<loginName>#{loginName}</loginName><loginPswd>#{loginPswd}</loginPswd><mobiles>#{mobiles}</mobiles><content>#{self.content}</content><fixedTime></fixedTime><sendId></sendId><extid></extid>"
      end
      response.body[:batch_send_response][:out]
    end
  end

  def self.soap_receive(account_id)

  end

  def http_transmit
    client = @account.settings.sms_http_gateway
    mobiles = self.mobiles
    content = self.content.encode!('GBK')
    uid = @account.settings.sms_http_uid
    pwd = @account.settings.sms_http_pwd
    if Rails.env.production?
      request = "uid=#{uid}&pwd=#{pwd}&mobile=#{mobiles}&Msg=#{content}&spnum=0&OpType=0"
    else
      request = "uid=#{uid}&pwd=#{pwd}&mobile=#{@account.settings.sms_test_mobile}&Msg=#{content}&spnum=0&OpType=0"
    end
    full_resquest = URI.escape(client + request)
    send_request = HTTParty.get(full_resquest)
  end

  def self.http_receive(account_id)
    account = Account.find_by_id(account_id)
    client = account.settings.sms_http_receive_gateway
    uid = account.settings.sms_http_uid
    pwd = account.settings.sms_http_pwd
    request = "uid=#{account.settings.sms_http_uid}&pwd=#{account.settings.sms_http_pwd}"
    full_resquest = URI.escape(client + request)
    send_request = HTTParty.get(full_resquest)
  end

end

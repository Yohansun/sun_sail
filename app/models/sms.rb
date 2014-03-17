# -*- encoding : utf-8 -*-
class Sms
  require "savon"
  require "collections"

  attr_accessor :account, :mobiles, :content

  def initialize(account, content, mobiles)
    @account = account
    @content = content+'【Magic系统提醒】'
    @mobiles = mobiles
  end

  def transmit
    http_transmit
  end

  def self.receive(account_id)
    account = Account.find(account_id)
    Sms.http_receive(account_id)
  end

  # 企信通平台短信设置基本参数
  # settings.sms_http_gateway = "http://42.96.160.99/cosms/getinfo.aspx?"
  # settings.sms_http_uid = 59
  # settings.sms_http_pwd = 33726254
  # settings.sms_http_receive_gateway = "http://42.96.160.99/cosms/yuchen_mo.aspx?"

  def http_transmit
    client = @account.settings.sms_http_gateway
    mobiles = self.mobiles
    content = self.content.encode!('GBK')
    uid = @account.settings.sms_http_uid
    pwd = @account.settings.sms_http_pwd
    params = {uid:uid,pwd:pwd,mobile:mobiles,Msg:content,spnum:0,OpType:0}
    if !Rails.env.production?
      params[:mobile]=@account.settings.sms_test_mobile
    end
    request = params.to_query
    full_request = client + request
    send_request = HTTParty.get(full_request)
  end

  def self.http_receive(account_id)
    account = Account.find(account_id)
    client = account.settings.sms_http_receive_gateway
    uid = account.settings.sms_http_uid
    pwd = account.settings.sms_http_pwd
    request = "uid=#{account.settings.sms_http_uid}&pwd=#{account.settings.sms_http_pwd}"
    full_resquest = URI.escape(client + request)
    send_request = HTTParty.get(full_resquest)
  end

##### DEPRECATED START #####

  def soap_transmit
    loginName = @account.settings.loginName
    loginPswd = @account.settings.loginPswd
    sms_test_mobile = @account.settings.sms_test_mobile

    client = Savon.client(wsdl: @account.settings.sms_soap_gateway)
    if Rails.env.production?
      response = client.call(:batch_send) do
        message loginName: loginName,
                loginPswd: loginPswd,
                mobiles: self.mobiles,
                content: self.content,
                fixedTime: '',
                sendId: '',
                extid: ''
      end
      response.body[:batch_send_response][:out]
    else
      response = client.call(:batch_send) do
        message loginName: loginName,
                loginPswd: loginPswd,
                mobiles: sms_test_mobile,
                content: self.content,
                fixedTime: '',
                sendId: '',
                extid: ''
      end
      response.body[:batch_send_response][:out]
    end
  end

  def self.soap_receive(account_id)
  end

##### DEPRECATED END #####

end

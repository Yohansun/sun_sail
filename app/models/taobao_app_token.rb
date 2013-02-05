# == Schema Information
#
# Table name: taobao_app_tokens
#
#  id                            :integer(4)      not null, primary key
#  account_id                    :integer(4)
#  access_token                  :string(255)
#  taobao_user_id                :string(255)
#  taobao_user_nick              :string(255)
#  refresh_token                 :string(255)
#  created_at                    :datetime        not null
#  updated_at                    :datetime        not null
#  last_refresh_at               :datetime
#  trade_source_id               :integer(4)
#  refresh_token_last_refresh_at :datetime
#

# encoding : utf-8 -*-
class TaobaoAppToken < ActiveRecord::Base
  belongs_to :trade_source
  attr_accessible :access_token, :refresh_token, :last_refresh_at, :refresh_token_last_refresh_at, :re_expires_in, :r1_expires_in, :r2_expires_in, :w1_expires_in,  :w2_expires_in
  def check_or_refresh!
    if last_refresh_at.nil? || r2_expires_in.nil? || (last_refresh_at.present? && r2_expires_in.present? && r2_expires_in < Time.now - last_refresh_at)  
      base_url = "https://oauth.taobao.com/token?"
      params = {
                  client_id: TradeSetting.taobao_app_key,
                  client_secret: TradeSetting.taobao_app_secret,
                  grant_type: 'refresh_token',
                  refresh_token: refresh_token
                }.to_params
      response = HTTParty.post(base_url + params).parsed_response
      if response['access_token'].present?
        update_attributes(access_token: response['access_token'], 
                                          last_refresh_at: Time.now,
                                          refresh_token: response['refresh_token'], 
                                          refresh_token_last_refresh_at: Time.now,
                                          re_expires_in: response['re_expires_in'], 
                                          r1_expires_in:  response['r1_expires_in'], 
                                          r2_expires_in: response['r2_expires_in'], 
                                          w1_expires_in: response['w1_expires_in'],  
                                          w2_expires_in:  response['w2_expires_in'], 
                                          )
      else
        if TradeSetting.enable_token_error_notify
          Notifier.app_token_errors(self,response).deliver
        end
      end
    end
  end
end

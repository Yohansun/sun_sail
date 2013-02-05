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

	attr_accessible :access_token, :refresh_token, :last_refresh_at, :refresh_token_last_refresh_at, :trade_source_id

	def check_or_refresh!

	  access_token_refresh = Time.now - (self.last_refresh_at || Time.now.yesterday)
	  refresh_token_refresh = Time.now - (self.refresh_token_last_refresh_at || Time.now.yesterday)

	  if (access_token_refresh >= 11536001 || refresh_token_refresh > 11536001) && TradeSetting.enable_token_error_notify #1 hours

			base_url = "https://oauth.taobao.com/token?"

			params = {
									client_id: TradeSetting.taobao_app_key,
									client_secret: TradeSetting.taobao_app_secret,
									grant_type: 'refresh_token',
									refresh_token: self.refresh_token

								}.to_params

			response = HTTParty.post(base_url + params).parsed_response
			p response
			if response['access_token'].present?
				self.update_attributes(access_token: response['access_token'], last_refresh_at: Time.now, refresh_token: response['refresh_token'], refresh_token_last_refresh_at: Time.now)
				p "successful update access_token and refresh_token"
				TradeSetting.enable_token_error_notify = true
			else
				p response['error_description']
				if TradeSetting.enable_token_error_notify
			  	Notifier.app_token_errors(self,response).deliver
			  	TradeSetting.enable_token_error_notify = false
			  end
			end

		end

	end

end

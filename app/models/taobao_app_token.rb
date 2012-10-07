# encoding : utf-8 -*- 
class TaobaoAppToken < ActiveRecord::Base
	
	belongs_to :trade_source
	
	attr_accessible :access_token, :refresh_token, :last_refresh_at
	
	def check_or_refresh!
	
	  time_since_last_refresh = Time.now - (self.last_refresh_at || Time.now.yesterday)
	 
	  if time_since_last_refresh >= 21600 #6 hours
	
			base_url = "https://oauth.taobao.com/token?"
			
			params = { 
									client_id: TradeSetting.taobao_app_key,
									client_secret: TradeSetting.taobao_app_secret, 
									grant_type: 'refresh_token',
									refresh_token: self.refresh_token
									
								}.to_params		
								
			response = HTTParty.post(base_url + params).parsed_response
			if response['access_token'].present?
				self.update_attributes(access_token: response['access_token'], refresh_token: response['refresh_token'], last_refresh_at: Time.now)
				p "successful update access_token"
			else 
				p response['error_description']	
			  Notifier.app_token_errors(self,response).deliver
			end
		
		end	
		
	end
	
end
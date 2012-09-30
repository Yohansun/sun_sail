# encoding : utf-8 -*- 
class TaobaoAppToken < ActiveRecord::Base
	
	attr_accessible :access_token, :refresh_token
	
	def check_or_refresh!
	
	  time_since_last_refresh = Time.now - (self.last_refresh_at || Time.now.yesterday)
	 
	  if time_since_last_refresh >= 43200 #12 hours
	
			base_url = "https://oauth.taobao.com/token?"
			
			params = { 
									client_id: TradeSetting.taobao_app_key,
									client_secret: TradeSetting.taobao_app_secret, 
									grant_type: 'refresh_token',
									refresh_token: self.refresh_token
									
								}.to_params		
								
			response = HTTParty.post(base_url + params).parsed_response
			if response['access_token'].present?
				self.update_attributes(access_token: response['access_token'])
				self.update_attributes(refresh_token: response['refresh_token'])
				self.update_attributes(last_refresh_at: Time.now)
				p "successful update access_token"
			else 
				p response['error_description']	
			end
		
		end	
		
	end
	
end
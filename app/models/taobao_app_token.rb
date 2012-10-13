# encoding : utf-8 -*- 
class TaobaoAppToken < ActiveRecord::Base
	
	belongs_to :trade_source
	
	attr_accessible :access_token, :refresh_token, :last_refresh_at, :refresh_token_last_refresh_at	
	
	def check_or_refresh!
	
	  access_token_refresh = Time.now - (self.last_refresh_at || Time.now.yesterday)
	  refresh_token_refresh = Time.now - (self.refresh_token_last_refresh_at || Time.now.yesterday)
	   
	  if access_token_refresh >= 3600 || refresh_token_refresh > 3600 #1 hours
	
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
				self.update_attributes(access_token: response['access_token'], last_refresh_at: Time.now)
				p "successful update access_token"
				if self.refresh_token != response['refresh_token']
					self.update_attributes(refresh_token: response['refresh_token'], refresh_token_last_refresh_at: Time.now)
					p "successful update refresh_token"
				end	
			else 
				p response['error_description']	
			  Notifier.app_token_errors(self,response).deliver
			end
		
		end	
		
	end
	
end
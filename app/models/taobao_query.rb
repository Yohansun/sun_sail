# encoding : utf-8 -*- 
module TaobaoQuery	
	require 'crack/json'
	require 'oauth2'

  def self.get(options = {}, source_name=nil)
  	#source_name用来选择订单源，代替之前的Taobaofu.select_source 
  	token = TaobaoAppToken.find_by_name(source_name) || TaobaoAppToken.find_by_name('天猫')
  	token.check_or_refresh!
  	base_url = 'https://eco.taobao.com/router/rest?'
  	
  	#sorted_params
  	sorted_params = {  
        access_token: token.access_token,
        format:      'json',
        v:           '2.0',
        timestamp:   Time.now.strftime("%Y-%m-%d %H:%M:%S")
      }.merge!(options)
      
    #generate_query_string
    params_array = sorted_params.sort_by { |k,v| k.to_s }
    total_param = params_array.map { |key, value| key.to_s+"="+value.to_s }
    generate_query_string = URI.escape(total_param.join("&"))  
  	 
  	data = HTTParty.post(base_url + generate_query_string).parsed_response.to_json #Hash2JSON  
    response = Crack::JSON.parse(data)
	end	
end	


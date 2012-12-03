# -*- encoding : utf-8 -*-
class LogisticRate < ActiveRecord::Base

  attr_accessible  :logistic_id, :mobile, :send_at, :seller_id, :tid, :score
  
  def self.rates_array(seller_id, start_date, end_date, logistic_id)
  	rates = LogisticRate.where(seller_id: seller_id, logistic_id: logistic_id).where(:send_at => start_date..end_date)
  	arr = Array.new(8,0)
  	if rates
	  	arr[0] = rates.count #订单数 
	  	arr[1] = arr[0] * 5 #物流总分 
	  	arr[2] = rates.sum(:taobao_rate_score) #物流评分 
	  	arr[3] = (arr[2].to_f / arr[1]).round(4) * 100 #物流评分满意度 
	  	valid_rates = rates.where("score in (1,3,5)")
	  	if valid_rates
	  		arr[4] = valid_rates.count #有效回复数
	  		arr[5] = arr[4] * 5 #短信总分
	  		if arr[4] != 0	
	  			arr[6] = valid_rates.sum(:score) #短信评分
	  		end
	  		if arr[5] != 0
	  			arr[7] = (arr[6].to_f / arr[5]).round(4) * 100 #短信评分满意度
	  		end
	  	end	
	  end	
	  arr
  end	

  def display_name
  	seller_name = Seller.find_by_id(seller_id).try(:name)
  	logistic_name = Logistic.find_by_id(logistic_id).try(:name)
  	"#{seller_name}-#{logistic_name}" 	 	
  end	

end

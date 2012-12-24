# == Schema Information
#
# Table name: logistic_rates
#
#  id                :integer(4)      not null, primary key
#  seller_id         :integer(4)
#  logistic_id       :integer(4)
#  score             :integer(4)
#  mobile            :string(255)
#  tid               :string(255)
#  send_at           :datetime
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  taobao_rate_score :integer(4)
#

# -*- encoding : utf-8 -*-
class LogisticRate < ActiveRecord::Base

  attr_accessible  :logistic_id, :mobile, :send_at, :seller_id, :tid, :score, :taobao_rate_score
  
  def self.rates_array(seller_id, start_date, end_date, logistic_id)
  	rates = LogisticRate.where(seller_id: seller_id, logistic_id: logistic_id).where(:send_at => start_date..end_date)
  	arr = Array.new(8,0)
  	if rates
	  	arr[0] = rates.count #订单数
	  	taobao_rates = rates.where("taobao_rate_score in (1,3,5)") 
	  	arr[1] = taobao_rates.count * 5 #订单总分 
	  	arr[2] = taobao_rates.sum(:taobao_rate_score) #订单评分 
	  	arr[3] = ((arr[2].to_f / arr[1]) * 100).round(2) #订单评分满意度 
	  	arr[3] = 0 if arr[1] == 0
	  	valid_rates = rates.where("score in (1,3,5)")
	  	if valid_rates
	  		arr[4] = valid_rates.count #有效回复数
	  		arr[5] = arr[4] * 5 #短信总分
	  		if arr[4] != 0	
	  			arr[6] = valid_rates.sum(:score) #短信评分
	  		end
	  		if arr[5] != 0
	  			arr[7] = ((arr[6].to_f / arr[5])* 100).round(2) #短信评分满意度
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

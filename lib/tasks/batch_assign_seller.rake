# -*- encoding : utf-8 -*-
task :batch_assign_seller => :environment do
  file = ENV['file']
  type = ENV['type']
  seller_id = ENV['seller_id']
  seller_name = ENV['seller_name']
	if file.present? && type.present?
    if type == "match" #分到匹配的经销商
      CSV.foreach("#{Rails.root}/lib/#{file}") do |row|
        tid = row[0]  
        trade = Trade.where(tid: tid).first
        if trade
          matched_seller = trade.matched_seller_with_default(nil)
          trade.seller_id = matched_seller.id
          trade.seller_name = matched_seller.name
          trade.dispatched_at = Time.now
          trade.save
          trade.operation_logs.create(operated_at: Time.now, operation: '技术人员手动分流')
          p "#{tid} matched & re-dispatched"
        else
          p "trade not found"
        end  
      end  
    elsif type == "assign" && seller_id.present? && seller_name.present? #分到特定的经销商
      CSV.foreach("#{Rails.root}/lib/#{file}") do |row|
        tid = row[0]  
        trade = Trade.where(tid: tid).first
        if trade
          trade.seller_name = seller_name
          trade.seller_id = seller_id
          trade.dispatched_at = Time.now
          trade.save
          trade.operation_logs.create(operated_at: Time.now, operation: '技术人员手动分流')
          p "#{tid} assigned & re-dispatched"
        else
          p "trade not found"
        end  
      end  
    end          
  end 
end
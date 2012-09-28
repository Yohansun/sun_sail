# -*- encoding:utf-8 -*-

desc "更新数据Key"
task :update_keys => :environment do

  # JingdongTrade.all.each {|t| t.rename(:order_state, :status);t.save}
  # JingdongTrade.all.each {|t| t.rename(:order_remark, :buyer_message);t.save}
  # TaobaoPurchaseOrder.all.each {|t| t.rename(:supplier_memo, :seller_memo);t.save}
  # TaobaoPurchaseOrder.all.each {|t| t.rename(:memo, :buyer_message);t.save}
  # trades = Trade.all.each {|t| t.orders.each {|o| o = o.color_num.to_a;t.save}}
  p "STARTING~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

  for trade in Trade.all
    for order in trade.orders
      color_num_array = []
      color_hexcode_array = []
      color_name_array = []
      temp_num = trade._type == "JingdongTrade" ? order.item_total : order.num
      if order.color_num.present? && order.color_num.class == String
      	temp1 = order.color_num
      	color = Color.find_by_num temp1
      	temp2 = color.hexcode
      	temp3 = color.name

      	temp_num.times do |i|
      		color_num_array[i] = temp1
      		color_hexcode_array[i] = temp2
      		color_name_array[i] = temp3
      	end

	      order.color_num = color_num_array
	      order.color_hexcode = color_hexcode_array
	      order.color_name = color_name_array
	      
	      order.save(validate: false)
	    end
    end
  trade.save(validate: false)
  p trade.tid
  p "succeed!"
  end
end
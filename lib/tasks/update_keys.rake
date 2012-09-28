# -*- encoding:utf-8 -*-

desc "更新数据Key"
task :update_keys => :environment do
  ##字段更名
  # JingdongTrade.all.each {|t| t.rename(:order_state, :status);t.save}
  # JingdongTrade.all.each {|t| t.rename(:order_remark, :buyer_message);t.save}
  # TaobaoPurchaseOrder.all.each {|t| t.rename(:supplier_memo, :seller_memo);t.save}
  # TaobaoPurchaseOrder.all.each {|t| t.rename(:memo, :buyer_message);t.save}
  # trades = Trade.all.each {|t| t.orders.each {|o| o = o.color_num.to_a;t.save}}

  ##修改调色信息
  # for trade in Trade.all
  #   for order in trade.orders
  #     color_num_array = []
  #     color_hexcode_array = []
  #     color_name_array = []
  #     temp_num = trade._type == "JingdongTrade" ? order.item_total : order.num
  #     if order.color_num.present? && order.color_num.class == String
  #     	temp1 = order.color_num
  #     	color = Color.find_by_num temp1
  #     	temp2 = color.hexcode
  #     	temp3 = color.name

  #     	temp_num.times do |i|
  #     		color_num_array[i] = temp1
  #     		color_hexcode_array[i] = temp2
  #     		color_name_array[i] = temp3
  #     	end

	 #      order.color_num = color_num_array
	 #      order.color_hexcode = color_hexcode_array
	 #      order.color_name = color_name_array
	      
	 #      order.save(validate: false)
	 #    end
  #   end
  # trade.save(validate: false)
  # p trade.tid
  # p "succeed!"
  # end
   p "STARTING CS_MEMO~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

  ##修改客服备注字段信息
  for trade in Trade.all
    unless trade.cs_memo.blank?
      trade.has_cs_memo = true
      p trade.tid
      p trade.has_cs_memo
    else
      trade.orders.each do |order|
        unless order.cs_memo.blank?
          trade.has_cs_memo = true
          p trade.tid
          p trade.has_cs_memo
          break
        end
      end
      trade.has_cs_memo = false
    end
    trade.save
  end

  p "STARTING COLOR_INFO~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  
  for trade in Trade.all
    trade.orders.each do |order|
      unless order.color_num.blank?
        trade.has_color_info = true
        p trade.tid
        p trade.has_color_info
        break
      else
      trade.has_color_info = false
      end
    end
    trade.save
  end
end
# -*- encoding:utf-8 -*-

task :update_keys => :environment do
   JingdongTrade.all.each {|t| t.rename(:order_state, :buyer_message);t.save}
   JingdongTrade.all.each {|t| t.rename(:order_remark, :status);t.save}
   TaobaoPurchaseOrder.all.each {|t| t.rename(:supplier_memo, :seller_memo);t.save}
   TaobaoPurchaseOrder.all.each {|t| t.rename(:memo, :buyer_message);t.save}
end
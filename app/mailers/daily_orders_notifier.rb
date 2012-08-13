# -*- encoding : utf-8 -*-
class DailyOrdersNotifier < ActionMailer::Base
  default :from => "E-Business@nipponpaint.com.cn"

  def yesterday
    reciever = %w(michelle@doorder.com wynn@doorder.com zhongjing@nipponpaint.com.cn LuJingRNMD@nipponpaint.com.cn QiYun@nipponpaint.com.cn SunYi@nipponpaint.com.cn ZhuYanQing@nipponpaint.com.cn YaoYanMing@nipponpaint.com.cn)
    cc = %w(clover@doorder.com blythe@doorder.com hui@networking.io)
    # reciever = %w(xiaoliang@networking.io)
    # cc = %w(zxl51@qq.com)

    yesterday = Time.now - 1.day
    year = yesterday.year
    month = yesterday.month
    day = yesterday.day

    yesterday_begin = Time.local(year,month,day,0,0,0).utc
    yesterday_end =  Time.local(year,month,day,23,59,59).utc

    @jingdong_trades = JingdongTrade.where(:created => yesterday_begin..yesterday_end)
    @jingdong_paid_trades = JingdongTrade.where(:created => yesterday_begin..yesterday_end)
    @jingdong_paid = @jingdong_paid_trades.sum(:order_payment)
    @taobao_purchase_orders =  TaobaoPurchaseOrder.where(:created => yesterday_begin..yesterday_end)
    @taobao_purchase_paid_orders =  TaobaoPurchaseOrder.where(:pay_time => yesterday_begin..yesterday_end)
    @taobao_purchase_paid = @taobao_purchase_paid_orders.sum(:distributor_payment)
    mail(:to => reciever, :cc => cc,:subject => "#{year}年#{month}月#{day}日立邦(京东,分销)电商数据")
  end
end

# -*- encoding : utf-8 -*-

class Trade
  include Mongoid::Document
  include Mongoid::Timestamps

  field :seller_id, type: Integer
  field :dispatched_at, type: DateTime     # 分流时间
  field :delivered_at, type: DateTime      # 发货时间

  field :cs_memo, type: String             # 客服备注

  field :invoice_type, type: String        # 发票信息
  field :invoice_content, type: String
  field :invoice_date, type: String

  field :logistic_code, type: String       # 物流公司代码
  field :logistic_waybill, type: String    # 物流运单号

  # model 属性方法

  # 物流公司名称
  def logistic_company
    case logistic_code
    when 'YTO'
      '圆通快递'
    when 'ZTO'
      '中通速递'
    else
      '其他'
    end
  end

  def cc_emails
    extra_cc = %W(E-Business@nipponpaint.com.cn chendonglin@nipponpaint.com.cn shenweiyu@nipponpaint.com.cn zhangqin@nipponpaint.com.cn)
    if self.seller
      cc = self.seller.ancestors.map { |e|
        if e.cc_emails
          e.cc_emails.split(",")
        end
      }.flatten.compact.map { |e| e.strip }  << extra_cc
      cc.flatten
    end
  end

  def seller
    if self.seller_id
      Seller.find(self.seller_id)
    end
  end

  def has_color_info
  	self.orders.each do |order|
  		unless order.color_num.blank?
  			return true
  			break
  		end
  	end
  end


  # 操作方法

  def deliver!
    raise "EMPTY METHOD!"
  end
end
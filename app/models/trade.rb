# -*- encoding : utf-8 -*-

class Trade
  include Mongoid::Document
  include Mongoid::Paranoia
  include Mongoid::Versioning
  include Mongoid::Timestamps

  field :trade_source_id, type: Integer

  field :seller_id, type: Integer
  field :dispatched_at, type: DateTime                    # 分流时间
  field :delivered_at, type: DateTime                     # 发货时间

  field :cs_memo, type: String                            # 客服备注

  # 发票信息
  field :invoice_type, type: String
  field :invoice_name, type: String
  field :invoice_content, type: String
  field :invoice_date, type: DateTime
  field :invoice_number, type: String

  field :logistic_code, type: String                      # 物流公司代码
  field :logistic_waybill, type: String                   # 物流运单号

  field :seller_confirm_deliver_at, type: DateTime        # 确认发货
  field :seller_confirm_invoice_at, type: DateTime        # 确认开票

  # 拆单相关
  field :splitted, type: Boolean, default: false
  field :splitted_tid, type: String

  #单据是否已打印
  field :deliver_bill_printed_at, type: DateTime
  field :logistic_printed_at, type: DateTime

  attr_accessor :matched_seller

  # validate :color_num_do_not_exist, :on => :update

  # def color_num_do_not_exist
  #   color_nums = Color.all.map {|color| color.num}
  #   count = 0
  #   self.orders.each do |order|
  #     for num in color_nums
  #       if order.color_num == num
  #         count += 1
  #         break
  #       end
  #     end
  #     if order.color_num == nil or order.color_num == ""
  #       count += 1
  #     end
  #   end
  #   if count != self.orders.count
  #     errors.add(:self, "Blank color_num")
  #   end
  # end

  # model 属性方法
  def trade_source_name
    if trade_source_id
      TradeSource.find(trade_source_id).name
    end
  end

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
    extra_cc = %W(E-Business@nipponpaint.com.cn shenweiyu@nipponpaint.com.cn zhangqin@nipponpaint.com.cn wuhangjun@nipponpaint.com.cn ZhaoMengMeng@nipponpaint.com.cn caozhixiong@nipponpaint.com.cn shaolixing@nipponpaint.com.cn YanFei.Allen@nipponpaint.com.cn gaoyulin@nipponpaint.com.cn)
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

  def matched_seller
    @matched_seller ||= SellerMatcher.new(self).matched_seller
  end

  def area
    address = self.receiver_address_array
    state = city = area = nil
    state = Area.find_by_name address[0]
    city = state.children.where(name: address[1]).first if state
    area = city.children.where(name: address[2]).first if city
    area || city || state
  end

  # 操作方法
  def deliver!
    raise "EMPTY METHOD!"
  end

  def receiver_address_array
    # overwrite this method
    # 请按照 省市区 的顺序生成array
    []
  end

  def dispatch!
    # overwrite this method
  end

  def out_iids
    # overwrite this method
  end
end
class Trade
  include Mongoid::Document
  include Mongoid::Timestamps

  field :seller_id, type: Integer
  field :dispatched_at, type: DateTime # 分流时间
  field :delivered_at, type: DateTime # 发货时间

  field :cs_memo, type: String # 客服备注

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

end
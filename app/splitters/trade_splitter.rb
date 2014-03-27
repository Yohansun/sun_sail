#encoding: utf-8
module TradeSplitter

  def split_trades
    self.class.where(parent_type: 'split_trade',parent_id: id)
  end

  def can_split?
    !pay_time.nil? && seller_id.nil? && orders.map(&:num).sum > 1 && orders.all?{|order| order.refund_status == 'NO_REFUND'}
  end

  def split_trade(args)
    news_trades = create_split_trades(args)


    self.errors.add(:base,validates_trades(news_trades))

    return self if self.errors.present?

    if news_trades.map(&:save).uniq != [true]
      reset_split_trades(news_trades)
    else
      self.destroy
    end

    self
  end

  # 重置拆分
  # 如果参数为空, 则重置父订单及相关的被拆分订单
  # 如果指定了参数,则重置当前拆分的订单
  def reset_split_trades(trades=nil)
    Trade.unscoped.where(id: trades.nil? ? parent_id : id).update_all(deleted_at: nil)
    trades = self.class.where(parent_id: parent_id,parent_type: 'split_trade') if trades.nil?
    trades.select {|t| !t.new_record?}.map(&:delete!)
  end

  def can_reset_split?
    parent_id.present? && parent_type_split_trade? && self.class.where(parent_type: 'split_trade',parent_id: parent_id).distinct(:seller_id).compact.blank?
  end

  private
  def find_by_order(oid)
    orders.to_a.find {|order| order.oid == oid}
  end

  # args:
  #   [
  #    {"orders"=>{"0"=>{"oid"=>"450569387947709", "num"=>"1"}}, "total_fee"=>"1", "promotion_fee"=>"1", "post_fee"=>"1", "payment"=>"3"},
  #    {"orders"=>{"0"=>{"oid"=>"450569387967709", "num"=>"1"}, "1"=>{"oid"=>"450569387957709", "num"=>"1"}}, "total_fee"=>"299",
  #     "promotion_fee"=>"19", "post_fee"=>"29", "payment"=>"347"}
  #   ]
  def create_split_trades(args)
    news_trades = []
    args.each_with_index do |arg,i|
      trade = self.class.new
      trade_attributes = self.attributes.except(*["versions","_id","_type","deleted_at"])
      trade_attributes.merge!({"tid" =>  self.tid.dup << "-#{i+1}",
      "promotion_fee" =>  arg["promotion_fee"].to_f, # 优惠
      "total_fee"    =>   arg["total_fee"].to_f, # 订单金额
      "post_fee"      =>  arg["post_fee"].to_f, #邮费
      "payment"       =>  arg["payment"].to_f, # 订单实付金额
      "taobao_orders" => [],
      "parent_id"     => id,
      "parent_type"   => 'split_trade',
      "created_at"    => Time.now,
      "orders"        => []}
      )
      trade.assign_attributes(trade_attributes)
      if arg["orders"].nil?
        self.errors.add(:base,"请选择商品") and return self
      else
        arg["orders"].values.each do |order|
          torder = find_by_order(order["oid"])
          trade.orders.build(torder.attributes.except(*["_id","_type"]).merge({num: order["num"]}))
        end
      end
      news_trades << trade
    end
    news_trades
  end

  def validates_trades(news_trades)
    errors = []
    errors << "不满足拆分条件"    if not can_split?
    errors << news_trades.collect{|t| t.errors.full_messages}.flatten.join(',') if news_trades.map(&:errors).any? {|t| !t.blank?}
    errors << "活动优惠错误"      if promotion_fee != news_trades.map(&:promotion_fee).sum
    errors << "订单总金额错误"    if total_fee != news_trades.map(&:total_fee).sum
    errors << "邮费错误"         if post_fee != news_trades.map(&:post_fee).sum
    errors << "订单实付金额错误"   if payment != news_trades.map(&:payment).sum
    errors
  end
end
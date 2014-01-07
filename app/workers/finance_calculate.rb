# -*- encoding : utf-8 -*-

class FinanceCalculate
  include Sidekiq::Worker
  sidekiq_options :queue => :calculate_profit, unique: true, unique_job_expiration: 120

  def perform(trade_source_id)
  	trade_source = TradeSource.find trade_source_id
  	trade_store_source = trade_source.id
  	trade_store_name = trade_source.name
  	account_id = trade_source.account_id

    records = TradeRecord.between(create_time: (Time.now - 1.month).beginning_of_day .. (Time.now - 1.month).end_of_month).where(trade_source_id: trade_source_id )
    #店铺支付宝总收入
    trade_revenue = 0
    postfee_revenue = 0 #运费
    Trade.between(create_time: (Time.now - 1.month).beginning_of_day .. (Time.now - 1.month).end_of_month).where(trade_source_id: trade_source_id, status: "TRADE_FINISHED").each{|trade| postfee_revenue += trade.post_fee}
    records.each{|r| trade_revenue += r.get_surplus}

    if r_statement = ReconcileStatement.create(audit_time: Time.now, account_id: account_id, trade_store_source: trade_store_source, trade_store_name: trade_store_name)
      reconcile_statement_id = r_statement.id
      special_products_alipay_revenue = 0 #特供商品支付宝收入
      # postfee_revenue = 0 #运费
      adjust_amount = 0 #调整金额
      base_fee_percent = 5 #基准价比例
      audit_amount_percent = 5 #特供商品结算金额比例
      achievement = 0 #业绩
      special_products_audit_amount_percent = 5 #特供商品结算金额比例
      account_profit_percent_a = 5 #账户提留比例
      account_profit_percent_b = 5 #账户提留比例
      account_profit_percent_c = 5 #账户提留比例
      advertise_reserved_percent_a = 5 #推广费预留比例
      advertise_reserved_percent_b = 5 #推广费预留比例
      platform_deduction_percent_a = 5 #平台扣点比例
      platform_deduction_percent_b = 5 #平台扣点比例

      alipay_revenue = trade_revenue + special_products_alipay_revenue
      #基准价=（支付宝收入-运费）*自定义比例
      base_fee = (alipay_revenue - postfee_revenue) * base_fee_percent / 100
      #特供商品结算金额=特供商品支付宝收入*自定义比例
      special_products_audit_amount = special_products_alipay_revenue * special_products_audit_amount_percent / 100
      #结算金额=支付宝收入*自定义比例+特供商品结算金额+业绩
      audit_amount = alipay_revenue * audit_amount_percent / 100 + special_products_audit_amount + achievement
      #最终结算金额=结算金额+调整金额
      last_audit_amount = adjust_amount + audit_amount
      #账户提留=基准价*自定义比例+运费*自定义比例+特供商品支付宝收入*自定义比例
      account_profit = base_fee * account_profit_percent_a / 100 + postfee_revenue * account_profit_percent_b / 100 + special_products_alipay_revenue * account_profit_percent_c / 100
      #推广费预留=支付宝收入*自定义比例+特供商品支付宝收入*自定义比例
      advertise_reserved = alipay_revenue * advertise_reserved_percent_a / 100 + special_products_alipay_revenue * advertise_reserved_percent_b / 100
      #平台扣点=支付宝收入*自定义比例+特供商品支付宝收入*自定义比例
      platform_deduction = alipay_revenue  * platform_deduction_percent_a / 100 + special_products_alipay_revenue * platform_deduction_percent_b / 100
      user_id = 1
      ReconcileStatementDetail.create(
      	          reconcile_statement_id: reconcile_statement_id,
                  alipay_revenue: alipay_revenue,
                  postfee_revenue: postfee_revenue,
                  base_fee: base_fee,
                  last_audit_amount: last_audit_amount,
                  account_profit: account_profit,
                  advertise_reserved: advertise_reserved,
                  platform_deduction: platform_deduction,
                  special_products_alipay_revenue: special_products_alipay_revenue,
                  special_products_audit_amount: special_products_audit_amount,
                  audit_amount: audit_amount,
                  adjust_amount: adjust_amount,
                  base_fee_percent: base_fee_percent, 
                  special_products_audit_amount_percent: special_products_audit_amount_percent,
                  audit_amount_percent: audit_amount_percent,
                  account_profit_percent_a: account_profit_percent_a,
                  account_profit_percent_b: account_profit_percent_b,
                  account_profit_percent_c: account_profit_percent_c,
                  advertise_reserved_percent_a: advertise_reserved_percent_a,
                  advertise_reserved_percent_b: advertise_reserved_percent_b,
                  platform_deduction_percent_a: platform_deduction_percent_a,
                  platform_deduction_percent_b: platform_deduction_percent_b,
                  user_id: user_id,
                  achievement: achievement)
      r_statement.update_attribute(:balance_amount, audit_amount)
    end
  end
end
class CreateReconcileSellerDetail < ActiveRecord::Migration
  def change
    create_table :reconcile_seller_details do |t|
      t.integer :reconcile_statement_id
      t.string  :source                   #来源    
      t.integer :trade_source_name          #店铺名
      t.integer :alipay_revenue , default: 0   #支付宝收入
      t.integer :postfee_revenue, default: 0   #运费
      t.integer :base_fee, default: 0      #基准价
      t.integer :base_fee_rate, default: 2    #基准价rate
      t.integer :audit_amount, default: 0   #结算金额
      t.integer :special_products_alipay_revenue, default: 0   #特供商品支付宝收入
      t.integer :special_products_alipay_revenue_rate, default: 2  	
      t.integer :audit_amount_rate, default: 2
      t.integer :adjust_amount, default: 0    #调整金额
      t.integer :last_audit_amount, default: 0   #最终结算金额
      t.integer :user_id

      t.timestamps
    end
  end
end

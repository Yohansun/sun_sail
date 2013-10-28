#encoding: utf-8
class CreateRefundProducts < ActiveRecord::Migration
  def change
    create_table :refund_products do |t|
      t.integer   :refund_id    ,limit:   5..8              #退货id
      t.string    :buyer_name                               #退货人
      t.string    :mobile                                   #手机号
      t.string    :phone                                    #电话号码
      t.string    :zip                                      #邮编
      t.string    :status                                   #退货状态
      t.datetime  :refund_time                              #退货时间
      t.string    :tid                                      #退货订单号
      t.integer   :state_id                                 #省
      t.integer   :city_id                                  #市
      t.integer   :district_id                              #区
      t.string    :address                                  #退货地址
      t.text      :reason                                   #退货描述
      t.decimal   :total_price  ,default: 0.0,  null: false #交易总额
      t.decimal   :refund_fee   ,default: 0.0,  null: false #退货金额
      t.integer   :account_id
      t.string    :ec_name                                  #服务商 例如 淘宝
      t.boolean   :is_location  ,default: true, null: false #是否线下
      t.integer   :seller_id                                #所属经销商
      t.text      :status_operations                        #状态变更时间记录 格式为 [{status_name => :time => Time},.....]

      t.timestamps
    end
  end
end
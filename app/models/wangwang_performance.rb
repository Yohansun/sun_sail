# -*- encoding : utf-8 -*-
class WangwangPerformance 
  include Mongoid::Document
  

  field :date, type: Integer


  # 店铺总销售额

  field :payment, type: Float                     # 总付款：店铺当日，所有产生的交易成功的订单金额（包括静默销售）
  field :receivenum, type: Integer                # 总接待：店铺当日接待的用户数量
  field :kf_receivenum, type: Integer             # 询单人数：店铺当日有询问过客户的用户数量
  field :kf_paid_receivenum, type: Integer        # 付款人数：通过客服聊天有付款的用户数量
  field :kf_created_payment, type: Integer        # 下单金额：店铺当日或者前一日，通过客服聊天下单的订单金额
  field :kf_paid_payment, type: Float             # 付款金额：店铺当日通过客服付款的订单金额
  field :kf_payment_percentage, type: Float       # 付款金额%：付款金额/总付款

  # 询单->下单

  # 流失人数：统计店铺当日询单，当日或次日均为下单人数。因为需要统计两天的数据，所以统计数据将延迟1天出来；
  # 当日下单人数：统计店铺当日询单，当日下单人数；
  # 当日下单金额：统计店铺当日询单，当日下单金额；
  # 最终下单人数：统计店铺当日询单，当日或次日下单人数；
  # 最终下单金额：统计店铺当日询单，当日或次日下单金额；
  # 成功率：统计最终下单人数与询单人数的百分比；

  # 下单->付款

  # 下单人数：统计店铺前日或当日询单，当日下单人数；
  # 下单金额：统计店铺前日或当日询单，当日下单金额；
  # 流失人数：统计店铺前日或当日询单，当日下单但最终未付款人数。因为淘宝规则下单到付款有7天的缓冲期，所以统计数据将延迟8天出来；
  # 流失金额：统计店铺前日或当日询单，当日下单但最终未付款金额。因为淘宝规则下单到付款有7天的缓冲期，所以统计数据将延迟8天出来；
  # 当日付款人数：统计店铺前日或当日询单，当日下单且当日付款人数；
  # 当日付款金额：统计店铺前日或当日询单，当日下单且当日付款金额；
  # 最终付款人数：统计店铺前日或当日询单，当日下单且最终付款人数。因为淘宝规则下单到付款有7天的缓冲期，所以统计数据将延迟8天出来；
  # 最终付款金额：统计店铺前日或当日询单，当日下单且最终付款金额。因为淘宝规则下单到付款有7天的缓冲期，所以统计数据将延迟8天出来；
  # 成功率：统计最终付款人数与下单人数的百分比；


  # 协助服务：因为一笔交易的成功只能算在一个客服旺旺的名下，而同一个单子有可能会经过多个客服旺旺的共同努力，为了体现出这些付出了努力又没计入成功交易的客服旺旺的价值，所以引入了协助服务这个概念。

  field :assist_kf, type: Integer             # 协助跟进人数：统计当日客户下单后客服旺旺的跟进服务（催款或售后等）人数；
  field :assist_kf_fee, type: Integer             # 协助跟进参考金额：统计当日客户下单后客服旺旺的跟进服务（催款或售后等）参考金额；

 
  # 静默销售数据
  # 在付款判定和下单优先判定规则下 
  # 静默销售额=总付款-客服销售额
  # 静默销售占比=100%-客服销售占比
  # 在下单判定规则下 
  # 静默销售额=有效下单金额-有效客服下单金额
  # 静默销售占比=100%-客服销售占比

  #field :quiet_payment, type: Float              
  #field :quiet_payment_percentage, type: Float  

  # 店铺客单价 pcr = per customer transaction

  field :created_pcr, type: Float                 # 下单客单价：是按照店铺当天所有下单的订单计算的客单价；
  field :quiet_created_pcr, type: Float           # 静默下单客单价：不通过客服咨询的所有下单的订单计算的客单价
  field :paid_by_created_pcr, type: Float         # 有效下单客单价：是店铺当天下单并且最终付款的客单价，跟下单客单价的不同在于它不包括没有付款的订单
  field :quiet_paid_by_created_pcr, type: Float   # 有效静默下单客单价：是不通过客服咨询的店铺当天下单并且最终付款的客单价
  field :kf_paid_by_created_pcr, type: Float      # 有效客服下单客单价：客服落实的当天下单并且最终付款的客单价（该数据须延迟4天统计）
  field :paid_pcr, type: Float                    # 付款客单价：是按店铺当天买家付款总额计算的付款客单价，跟前面客单价的不同在于统计的时间基准，前面两个都是当天下单，付款客单价是当天付款。


  # 店铺总销售量和总购买人数

  field :paid_products, type: Integer             # 店铺付款件数：店铺当天买家付款商品的总件数
  field :paid_customers, type: Integer            # 店铺付款人数：店铺当天付款买家总人数
  field :kf_paid_products, type: Integer          # 团队付款件数：经客服服务当日付款的件数 
  field :kf_paid_customers, type: Integer         # 团队付款人数：经客服服务当日付款的人数
  field :quiet_paid_products, type: Integer       # 静默付款件数：当日静默付款件数
  field :quiet_paid_customers, type: Integer      # 静默付款人数：当日静默付款人数


end
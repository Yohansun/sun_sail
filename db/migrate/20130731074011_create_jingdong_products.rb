#encoding: utf-8
class CreateJingdongProducts < ActiveRecord::Migration
  def change
    create_table :jingdong_products do |t|
      t.integer :ware_id, :limit => 8,:null => false #商品ID
      t.string  :spu_id                              #spu ID
      t.integer :cid                                 #分类ID 三级类目ID
      t.integer :vender_id                           #商家ID
      t.integer :shop_id                             #店铺ID
      t.string  :ware_status                         #商品状态: #[[NEVER_UP:       从未上架],
                                                               #[CUSTORMER_DOWN:  自主下架]
                                                               #[SYSTEM_DOWN:     系统下架]
                                                               #[ON_SALE:         在售]
                                                               #[AUDIT_AWAIT:     待审核]
                                                               #[AUDIT_FAIL:      审核不通过]]
      t.string  :title                               #商品标题
      t.string  :item_num                            #货号
      t.string  :upc_code                            #UPC编码
      t.integer :transport_id                        #运费模板
      t.string  :online_time                         #最后上架时间
      t.string  :offline_time                        #最后下架时间
      t.string  :attribute_s                          #可选属性
      t.text    :desc                                #商品描述
      t.string  :producter                           #生产厂商
      t.string  :wrap                                #包装规格
      t.string  :cubage                              #长:宽:高(11:21:31)
      t.string  :pack_listing                        #包装清单
      t.string  :service                             #售后服务
      t.decimal :cost_price                          #进货价, 精确到2位小数，单位:元
      t.decimal :market_price                        #市场价, 精确到2位小数，单位:元
      t.decimal :jd_price                            #京东价,精确到2位小数，单位:元
      t.integer :stock_num                           #库存
      t.string  :logo                                #商品的主图
      t.string  :creator                             #录入人
      t.string  :status                              #状态：Delete:删除,Invalid:无效,Valid :有效
      t.integer :weight                              #重量,单位:公斤
      t.datetime :created                            #WARE_WARE创建时间
      t.datetime :modified                           #WARE_WARE修改时间
      t.string   :outer_id                           #外部id,商家设置的外部id（保留字段）
      t.string  :shop_categorys                      #自定义店内分类 206-208;207-207 (206(一级)-208(二级);207(一级)-207(一级))
      t.boolean :is_pay_first                        #是否先款后货 支付方式 false：非  true：是
      t.boolean :is_can_vat                          #发票限制： true为限制，false为不限制开增值税发票
      t.boolean :is_imported                         #是否进口商品： false为否，true为是
      t.boolean :is_health_product                   #是否保健品： false为否，true为是
      t.boolean :is_shelf_life                       #是否保质期管理商品, false为否，true为是
      t.integer :shelf_life_days                     #保质期： 0-99999范围区间
      t.boolean :is_serial_no                        #是否序列号管理： false为否，true为是
      t.boolean :is_appliances_card                  #大家电购物卡： false为否，true为是
      t.boolean :is_special_wet                      #是否特殊液体： false为否，true为是
      t.integer :ware_big_small_model                #商品件型： 
                                                     #0免费、1超大件、2超大件半件、3大件、4大件半件、5中件、6中件半件、7小件、8超小件
      t.integer :ware_pack_type                      #商品包装：
                                                     #1普通商品、2易碎品、3裸瓶液体、4带包装液体、5按原包装出库
      t.timestamps
    end
  end
end

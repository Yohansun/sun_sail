#encoding: utf-8
class CreateJingdongSkus < ActiveRecord::Migration
  def change
    create_table :jingdong_skus do |t|
      t.integer   :sku_id               #jingdong sku的id
      t.integer   :shop_id              #店铺id
      t.integer   :ware_id              #jingdong sku所属商品id
      t.string    :status               #jingdong sku状态
                                        # 有效：Valid
                                        # 无效：Invalid
                                        # 删除：Delete
      t.string    :attribute_s           #sku的销售属性组合字符串
                                        #（颜色，大小，等等，可通过类目API获取某类目下的销售属性）,格式是aid1:vid1;aid2:vid2
      t.integer   :stock_num            #库存
      t.decimal   :jd_price             #京东价,精确到2位小数，单位元
      t.decimal   :cost_price           #进货价, 精确到2位小数，单位元
      t.decimal   :market_price         #市场价, 精确到2位小数，单位元
      t.string    :outer_id             #外部id,商家设置的外部id
      t.datetime  :created              #jingdong sku创建时间
      t.datetime  :modified             #jingdong sku修改时间
      t.string    :color_value          #颜色对应的值
      t.string    :size_value           #尺码对应的值
      t.integer   :account_id
      t.timestamps
    end
  end
end

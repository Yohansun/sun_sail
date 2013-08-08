class CreateYihaodianProducts < ActiveRecord::Migration
  def change
    create_table :yihaodian_products do |t|
      t.string  :product_code   ,:null => false #商家产品编码
      t.string  :product_cname  ,:null => false #商家产品中文名称
      t.integer :product_id     ,:limit => 8    #产品ID(没有通过审核的产品是没有产品ID的)
      t.string  :ean13                          #产品条形码
      t.integer :category_id    ,:limit => 8    #产品类目ID
      t.integer :can_sale                       #上下架状态0：下架，1：上架
      t.string  :outer_id                       #外部产品ID
      t.integer :can_show                       #是否可见,1是0否
      t.integer :verify_flg                     # 产品审核状态:1.新增未审核;2.编辑待审核;3.审核未通过;4.审核通过;5.图片审核失败;6.文描审核失败;7:生码中(第一次审核中)
      t.integer :is_dup_audit                   #是否二次审核0：非二次审核；1：是二次审核
      t.string  :prod_img                       # 图片信息列表（逗号分隔，图片id、图片URL、主图标识之间用竖线分隔；其中1：表示主图，0：表示非主图）
      t.string  :prod_detail_url                #前台商品详情页链接（正式产品才会有）
      t.integer :brand_id       ,:limit => 8    #品牌Id
      t.string  :merchant_category_id           #商家产品类别。多个类别用逗号分隔

      t.timestamps
    end
  end
end

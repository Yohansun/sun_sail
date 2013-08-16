class CreateYihaodianSkus < ActiveRecord::Migration
  def change
    create_table :yihaodian_skus do |t|
      t.string  :product_code   ,:null => false #商家产品编码
      t.string  :product_cname  ,:null => false #商家产品中文名称
      t.integer :product_id     ,:limit => 8    #产品ID(没有通过审核的产品是没有产品ID的)
      t.string  :ean13                          #产品条形码
      t.integer :category_id    ,:limit => 8    #产品类目ID
      t.integer :can_sale                       #上下架状态0：下架，1：上架
      t.string  :outer_id                       #外部产品ID
      t.integer :can_show                       #是否可见,1是0否
      t.integer :account_id
      t.integer :parent_product_id,:limit => 8 # 父类产品ID

      t.timestamps
    end
  end
end

# -*- encoding : utf-8 -*-

desc "批量绑定京东商品和本地商品"
task :bind_jingdong_products_with_products => :environment do
  Account.find(10).jingdong_products.find_each do |jp|
    product = Account.find(10).products.find_by_outer_id(jp.item_num)
    if product.present?
      p product.name
      SkuBinding.create(resource_id: jp.jingdong_skus.first.id ,resource_type: "JingdongSku", sku_id: product.skus.first.id, number: 1)
    else
      p "------------"
      p jp.item_num
      p "------------"
      sub_item_nums = Account.find(10).products.all.select{|prod| p prod.outer_id if (jp.item_num =~ /#{prod.outer_id}/).present?}
      sub_item_nums.each do |sub_item_num|
        sub_product = Account.find(10).products.find_by_outer_id(sub_item_num)
        if sub_product.present?
          SkuBinding.create(resource_id: jp.jingdong_skus.first.id, resource_type: "JingdongSku", sku_id: sub_product.skus.first.id, number: 1)
        end
      end
    end
  end
end
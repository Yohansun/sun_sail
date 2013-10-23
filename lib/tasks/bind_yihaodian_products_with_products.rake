# -*- encoding : utf-8 -*-
require 'csv'
desc "批量绑定一号店商品和本地商品"
task :bind_yihaodian_products_with_products => :environment do
  records = CsvMapper.import("#{Rails.root}/lib/data_source/yihaodian_products.csv") do |csv|
    start_at_row 2
    [category, shop_category, product_code, product_name, seller_product_id, biaogan_outer_id, brand, market_price, jd_price, promote_price, storage]
  end

  records.each do |record|
    yp = Account.find(10).yihaodian_products.find_by_product_code(record.product_code)
    product = Account.find(10).products.find_by_outer_id(record.biaogan_outer_id)
    if yp.present?
      if product.present?
        SkuBinding.create(resource_id: yp.yihaodian_skus.first.id ,resource_type: "YihaodianSku", sku_id: product.skus.first.id, number: 1)
        p product.name
      else
        record.biaogan_outer_id.to_s.split("/").each do |sub_outer_id|
          sub_product = Account.find(10).products.find_by_outer_id(sub_outer_id)
          if sub_product.present?
            SkuBinding.create(resource_id: yp.yihaodian_skus.first.id ,resource_type: "YihaodianSku", sku_id: sub_product.skus.first.id, number: 1)
            p "-------------"
            p sub_product.name
            p "-------------"
          end
        end
      end
    end
  end
end
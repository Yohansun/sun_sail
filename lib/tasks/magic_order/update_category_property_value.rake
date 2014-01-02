# encoding: utf-8
desc "更新sku属性(更新属性值引发的问题, 如果一个商品引用了一个分类下面的一个属性,   后来该属性被编辑, 准确的说系统直接把这个属性删除了. 从而导致sku的属性不正确)"
namespace :magic_order do
  task :update_category_property_value => :environment do
    news = Hash[*CategoryPropertyValue.where(value: value_diffs.values).map {|v| [v.value,v.id]}.flatten]
    SkuProperty.where(cached_property_value: value_diffs.keys).find_each do |sku_property|
      news_value = value_diffs[sku_property.cached_property_value]
      news_value_id = news[news_value]
      sku_property.update_attributes(category_property_value_id: news_value_id) if news_value_id
    end
  end
end

def value_diffs
  {
    # old          news
    "32/XS"   => "N/32(XS)",
    "34/S"    => "P/34(S)",
    "36/M"    => "R/36(M)",
    "38/L"    => "U/38(L)",
    "40/XL"   => "X/40(XL)",
    "42/XXL"  => "E/42(XXL)",
    "44/XXXL" => "44(XXXL)"
  }
end
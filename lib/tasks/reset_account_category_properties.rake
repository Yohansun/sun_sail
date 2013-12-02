# -*- encoding:utf-8 -*-

# 追溯account_id为空的CategoryProperty
# rake update_category_property_account_id --trace RAILS_ENV=production
task :update_category_property_account_id => :environment do
  CategoryProperty.select("DATE(created_at) AS created_on, MIN(id) AS gte_id, MAX(id) AS lte_id").
  where(["account_id IS NULL"]).group("created_on").each do |cat_pro|
    gte_id = cat_pro["gte_id"]
    lte_id = cat_pro["lte_id"]

    sku = Sku.includes(:sku_properties => :category_property).
          where(["sku_properties.category_property_id >= ? AND sku_properties.category_property_id <= ? ", gte_id, lte_id]).first

    if sku
      puts "gte_id:#{gte_id}, lte_id:#{lte_id}, sku account: #{sku.account_id}"

      CategoryProperty.update_all(["account_id = ?", sku.account_id], ["id >= ? AND id<= ?", gte_id, lte_id])
    else
      puts "gte_id:#{gte_id}, lte_id:#{lte_id} sku is null"
    end
  end
end

# 删除重复的SKU属性信息
# rake reset_duplicate_property_value --trace RAILS_ENV=production
task :reset_duplicate_property_value => :update_category_property_account_id do
  puts "CategoryProperty count: #{CategoryProperty.count}"
  puts "CategoryPropertyValue count: #{CategoryPropertyValue.count}"
  puts "SkuProperty count: #{SkuProperty.count}"
  CategoryProperty.all.group_by{|p| "#{p.account_id} -- #{p.name}"}.each do |name, ps|
    next if ps.length == 1
    puts "property name: #{name}"
    first_property_id = ps.first.id
    all_property_ids = ps.map(&:id)

    property_values = CategoryPropertyValue.where(category_property_id: all_property_ids)
    if property_values
      first_property_value_id = property_values.first.id
      all_property_value_ids = property_values.map(&:id)

      SkuProperty.update_all({category_property_value_id: first_property_value_id, category_property_id: first_property_id},
                             category_property_value_id: all_property_value_ids)
    end

    SkuProperty.group("sku_id, category_property_value_id").having("COUNT(*) > 1").each do |s_p|
      SkuProperty.destroy_all(["id != ? AND sku_id = ? AND category_property_value_id = ?",
        s_p.id, s_p.sku_id, s_p.category_property_value_id])
    end

    CategoryPropertyValue.destroy_all(id: all_property_value_ids - [first_property_value_id])
    CategoryProperty.destroy_all(id: all_property_ids - [first_property_id])
  end

  puts "CategoryProperty count: #{CategoryProperty.count}"
  puts "CategoryPropertyValue count: #{CategoryPropertyValue.count}"
  puts "SkuProperty count: #{SkuProperty.count}"
end
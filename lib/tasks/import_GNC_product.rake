# -*- encoding : utf-8 -*-
require "csv"

desc "Imports new product for GNC"
task :import_new_product_for_GNC => :environment do
  puts '--- starting ---'
  account = Account.find 10
  Product.where(account_id: account.id).each do |product|
    if product.destroy
      p"#{product.name} delete success!!"
    end
  end

  category_property_id,category_property_values_id = "", ""

  CSV.foreach("#{Rails.root}/lib/data_source/GNC_product.csv") do |attributes|
    product_code,warehouse_code,product_name,category_property_value,category_name = attributes
    category = account.categories.where(name: category_name).first_or_create(use_days: 1)
    p "category_id = #{category.id}"
    unless current_account.category_properties.where(:name => "含量").length == 0
      same_length = []
      current_account.category_properties.where(:name => "含量").each do |cate|
        unless category_property_value == cate.values.map(&:value) *' | '
          same_length << category_property_value
        else
          category_properties = cate
        end
      end
      if same_length.length == current_account.category_properties.where(:name => "含量").length
        category_properties = category.category_properties.create(:name => "含量", :value_text => category_property_value, :value_type=> "1", :status => "1")
      end
    else
      category_properties = category.category_properties.create(:name => "含量", :value_text => category_property_value, :value_type=> "1", :status => "1")
    end

    new_product = Product.create(outer_id: product_code, account_id: account.id, name: product_name, category_id: category.id, storage_num: warehouse_code)
    p"name = #{new_product.name}"
    category.category_properties.each do |c|
      value = c.values.map(&:value) *' | '
      if value == category_property_value
        category_property_id = c.id
        category_property_values_list = c.values.map(&:id) *' | '
      end
    end
    sku = Sku.where(product_id: new_product.id, account_id: account.id).first_or_create(:sku_properties_attributes => {"#{category_property_id}" => {:category_property_value_id => category_property_values_list }})
    account.sellers.each do |seller|
      seller.stock_products.create(product_id: new_product.id, sku_id: sku.id, account_id: account.id, max: 999999, safe_value: 20)
    end
    p"#{product_name} create success!!"

  end

end
# encoding: utf-8
desc "重新设置顾客管理、仓库管理和商品管理列表页的 可显示列"
task :rest_list_page_visible_columns => :environment do
  reset_keys = %w(
                  customer_cols
                  customer_around_cols
                  customer_visible_cols
                  stock_in_bill_cols
                  stock_in_bill_visible_cols
                  stock_out_bill_cols
                  stock_out_bill_visible_cols
                  stock_bill_cols
                  stock_bill_visible_cols
                  stock_product_detail_cols
                  stock_product_detail_visible_cols
                  stock_product_all_cols
                  stock_product_all_visible_cols
                  product_cols
                  product_visible_cols
                  taobao_product_cols
                  taobao_product_visible_cols
                  )
  Account.all.each do |account|
    reset_settings ||= account.setting_values.select{|k_item| reset_keys.include?(k_item.first)}
    reset_settings.each do |key, value|
      puts "key: #{key}"
      account.settings[key] = value
    end
  end
end
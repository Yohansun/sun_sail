# -*- encoding: utf-8 -*-
require 'csv'
task :export_current_sku_bindings => :environment  do
  account_id = ENV['account_id']
  if account_id
    taobao_skus = TaobaoSku.where(account_id: 2)
  else
    taobao_skus = TaobaoSku.all 
  end   
  CSV.open("export_current_sku_bindings.csv", 'wb') do |csv| 
    csv << ['淘宝商品编码','本地商品编码','本地商品数量']  
    taobao_skus.each do |taobao_sku|
      taobao_product = taobao_sku.taobao_product
      unless taobao_product
        taobao_sku.destroy
        next
      end
      sku_bindings =  taobao_sku.sku_bindings
      sku_bindings.each_with_index do |binding, index| 
        sku = binding.sku
        unless sku
          binding.destroy
          next
        end  
        product = sku.product
        unless product
          sku.destroy
          binding.destroy
        end  
        if index != 0 
          taobao_outer_id = ''
        else
          taobao_outer_id = taobao_product.outer_id
        end 
        csv << [taobao_outer_id, product.outer_id, binding.number]
      end 
      csv << ['','','']  
    end  
  end    
end

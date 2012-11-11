# -*- encoding:utf-8 -*-

desc "添加新商品"
task :add_products_to_sellers => :environment do

  # 20121020
  # product_iids = ['ICI0054', 'ICI0056', 'ICI0059']

  # product_iids = ['ICI0062','ICI0063','ICI0064','ICI0065','ICI0066','ICI0067','ICI0068','ICI0069',
  #                 'ICI0070','ICI0071','ICI0072','ICI0073','ICI0074','ICI0075','ICI0076']

  # product_iids = ['ICI0050']


  # product_iids.each do |iid|
  #   puts 'work with ' + iid
  #   product = Product.find_by_iid iid

  #   unless product
  #     puts iid + ' product not found'
  #     next
  #   end

  #   color_ids = product.color_ids
  #   puts 'begin add to sellers'

  #   Seller.find_each do |seller|
  #     sp = seller.stock_products.where(product_id: product.id).first

  #     unless sp
  #       sp = seller.stock_products.build(
  #         product_id: product.id,
  #         max: 99999,
  #         safe_value: 20
  #       )
  #     end

  #     if sp.save
  #       puts 'creat stock product success'
  #       sp.color_ids = color_ids
  #       puts 'set color success'

  #       if sp.update_quantity!(100, '入库', seller.id)
  #         puts 'add num success'
  #       else
  #         puts 'add num fail'
  #       end
  #     else
  #       next
  #     end
  #   end

  #   puts iid + ' operation end'
  # end


  color = Color.find_by_num "10GG 76/153"
  if color
    Product.find_each do |p|
      p.color_ids = p.color_ids << color.id
    end

    StockProduct.find_each do |sp|
      sp.color_ids = sp.color_ids << color.id
    end
  else
    puts "color not found"
  end
end

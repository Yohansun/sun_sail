# -*- encoding:utf-8 -*-

desc "添加新商品"
task :add_products_to_sellers => :environment do

  # 20121020
  # product_iids = ['ICI0054', 'ICI0056', 'ICI0059']

  product_iids = ['ICI0063']

  product_iids.each do |iid|
    puts 'work with ' + iid
    product = Product.find_by_iid iid

    unless product
      puts iid + ' product not found'
      next
    end

    color_ids = product.color_ids
    puts 'begin add to sellers'

    Seller.find_each do |seller|
      sp = seller.stock_products.build(
        product_id: product.id,
        max: 99999,
        safe_value: 20
      )


      if sp.save
        puts 'creat stock product success'
      else
        next
      end


      sp.color_ids = color_ids

      puts 'set color success'

      if sp.update_quantity!(200, '入库', seller.id)
        puts 'add num success'
      else
        puts 'add num fail'
      end
    end

    puts iid + ' operation end'
  end
end

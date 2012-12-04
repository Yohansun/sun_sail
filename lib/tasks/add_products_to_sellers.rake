# -*- encoding:utf-8 -*-

desc "添加新商品"
task :add_products_to_sellers => :environment do

  # stock_sellers = []
  # ['上海', '成都','广州', '廊坊'].each do |name|
  #   name = name + '仓库'
  #   seller = Seller.new(
  #     name: name,
  #     fullname: name
  #   )

  #   stock_sellers << seller if seller.save
  # end

  # specila_area = 'I1P18L40063C4V04'
  # gz_not_set = 'I1P01L40052C4V04' 

  # array = [
  #   'I1P18L50061C4V04',
  #   'I1P18L50102C4V07',
  #   'I1P18L50060C4V03',
  #   'I1P18L40062C4V03',
  #   'I1P18L20110C4V04',
  #   'I1P18L20109C4V03',
  #   'I1P04L10028C0V01',
  #   'I1P04L10095C0V01',
  #   'I1P04L10027C0V01',
  #   'A1P14L20048C0W01',
  #   'I1P04L10026C0V01',
  #   'I1P04L10106C0V01',
  #   'I1P04L10056C0V00'
  # ]

  # array.each do |iid|
  #   product = Product.find_by_iid iid
  #   next unless product

  #   stock_sellers.each do |seller|
  #     sp = seller.stock_products.where(product_id: product.id).first

  #     unless sp
  #       sp = seller.stock_products.build(
  #         product_id: product.id,
  #         safe_value: 20
  #       )
  #     end

  #     sp.max = 99999
  #     sp.activity = 9000
  #     sp.actual = 9000

  #     if sp.save
  #       puts 'creat stock product success'
  #       # sp.color_ids = color_ids
  #       puts 'set color success'
  #     end
  #   end

  # end

  # Product.where("iid NOT IN (?)", array).find_each do |product|
  #   puts "work with #{product.iid}"

  #   # color_ids = product.color_ids
  #   puts 'begin add to sellers'

  #   Seller.find_each do |seller|
  #     sp = seller.stock_products.where(product_id: product.id).first

  #     unless sp
  #       sp = seller.stock_products.build(
  #         product_id: product.id,
  #         safe_value: 20
  #       )
  #     end

  #     sp.max = 99999
  #     sp.activity = 9000
  #     sp.actual = 9000

  #     if sp.save
  #       puts 'creat stock product success'
  #       # sp.color_ids = color_ids
  #       puts 'set color success'
  #     end
  #   end

  #   puts product.iid + ' operation end'
  # end

  area_map = {
    '福建省' => 1793,
    '广东省' => 1793,
    '吉林省' => 1794,
    '广西壮族自治区' => 1793,
    '贵州省' => 1792,
    '辽宁省' => 1794,
    '内蒙古自治区' => 1794,
    '宁夏回族自治区' => 1794,
    '青海省' => 1794,
    '海南省' => 1793,
    '山西省' => 1794,
    '陕西省' => 1794,
    '湖北省' => 1793,
    '湖南省' => 1793,
    '天津' => 1794,
    '四川省' => 1792,
    '新疆维吾尔自治区' => 1792,
    '云南省' => 1792,
    '重庆' => 1792,
    '安徽省' => 1791,
    '北京' => 1794,
    '江苏省' => 1791,
    '甘肃省' => 1794,
    '江西省' => 1791,
    '山东省' => 1791,
    '上海' => 1791,
    '浙江省' => 1791,
    '河北省' => 1794,
    '河南省' => 1794,
    '黑龙江省' => 1794
  }

  Area.roots.each do |area|
    if ['北京市', '上海市', '天津', '重庆'].include? area.name
      area.name = area.name.gsub('市', '')
    else
      area.name += '省' unless area.name.include?('自治区') || area.name.include?('省')
    end

    area.save

    area.children.each do |area|
      area.name += '市' unless area.name.include? '市'
      area.save
    end

    area.descendants.each do |descendant|
      seller_ids = descendant.seller_ids
      descendant.seller_ids = seller_ids << area_map[area.name]
    end
  end
end

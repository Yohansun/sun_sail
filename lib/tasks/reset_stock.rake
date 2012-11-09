# -*- encoding:utf-8 -*-
require "csv"
desc "更新多乐士库存"
task :reset_stock => :environment do

  flag = ENV['show'] == 'show'

  head = [
    "上海丽王", "上海好心情装饰材料有限公司", "杭州锦鹏贸易有限公司", "温州市嘉美涂料有限公司", "宁波经济技术开发区嘉诚化工有限公司", 
    "嘉兴秀州", "绍兴市顺畅化工有限公司", "台州市美亚涂料有限公司", "南京西湖漆油有限公司",
    "苏州市荣发油漆批发销售部", "无锡炳庚商贸有限公司", "青岛锦泽源商贸有限公司", "济南金孚太建材有限公司", 
    "广州市海珠区达江化工装饰材料经营部", "深圳市一方化工有限公司", "东莞市景裕装饰材料有限公司", "佛山市金盛化工有限公司", 
    "中山市沙溪创欣装饰涂料", "珠海冠珠化工有限公司", "昆明市西山区大观恒日建材经营部", "长沙市芙蓉区湘东油漆涂料经营部", 
    "厦门厦禾化工贸易有限公司", "南宁市泽海装饰材料有限责任公司", "福州鑫晟和贸易有限公司", "海南欣美装饰工程有限公司", "成都市新精华建材经营部", 
    "重庆三原色节能建筑有限公司", "武汉市青山区多乐士佳美建材经营部", "西安威尔佳装饰工程有限公司", "郑州（东）建材大世界贝斯特装饰材料商行", 
    "贵阳南明佳园建材经营部", "北京榕旭嘉建材经营部", "天津顶顶好装饰材料经营部", "沈阳市铁西区展辰鑫达油漆涂料经销处", "石家庄新永诺经贸有限公司", 
    "山西宏泰来商贸有限公司", "哈尔滨市道里区大乐装饰材料商店", "内蒙古呼和浩特市新城区康轩油漆经销部"
  ]

  StockProduct.delete_all

  not_exist_products = []
  not_exist_sellers = []

  CSV.foreach("#{Rails.root}/lib/data_source/dulux_stock_20121108.csv") do |row|
    product = Product.where("storage_num = '#{row[0]}' OR iid = '#{row[0]}'").first
    
    unless product
      puts "product #{row[0]} not exist"
      not_exist_products << row[0]
      next
    end

    p_cids = product.color_ids

    row[2...-1].each_with_index do |data, index|
      data = data.to_i
      seller = Seller.find_by_name head[index]

      unless seller
        puts "seller #{head[index]} not exist"
        not_exist_sellers << head[index]
        next
      end

      puts "#{product.id} #{seller.id}" 
      sp = StockProduct.new(
        product_id: product.id,
        seller_id: seller.id,
        activity: data,
        actual: data,
        max: 99999,
        safe_value: data > 10 ? 10 : 1
      )
      
      if sp.save!
        StockHistory.create!(
          operation: '入库',
          number: data,
          stock_product_id: sp.id,
          seller_id: seller.id,
          reason: '双十一备货库存'
        )
        sp.color_ids = p_cids
      end
    end
  end
  
  puts not_exist_sellers.uniq.inspect
  puts not_exist_products.uniq.inspect
end

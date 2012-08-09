# -*- encoding:utf-8 -*-

desc "添加特殊经销商区域"
task :add_speical_area => :environment do
  root = Area.root
  sp_root = root.areas.build(name: '特殊经销商', zip: '999900', area_type: 2)
  sp_root.id = 999900
  sp_root.save

  net_area = sp_root.areas.build(name: '网络仓', zip: '999901', area_type: 3)
  net_area.id = 999901
  net_area.save

  seller = Seller.find_by_name("立邦仓库经销商")
  net_area.seller_id = seller.id
  net_area.save
end
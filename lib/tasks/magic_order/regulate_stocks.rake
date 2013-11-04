#encoding: utf-8
namespace :magic_order do
  desc "校正错误库存数量(针对实际库存小于可用库存)来进行出入库的盘点"
  task :regulate_stocks => :environment do
    StockProduct.where("actual < activity").update_all("actual = activity")
  end
end
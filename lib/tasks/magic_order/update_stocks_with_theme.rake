#encoding: utf-8
namespace :magic_order do
  desc "更新theme旗舰店账户库存数据(删除该账户下所有的库存,再导入本地商品数据到库存)"
  task :update_stocks_with_theme => :environment do
    account_id = ENV["ACCOUNT_ID"] || 26
    seller_id = ENV["SELLER_ID"]
    seller_id = Seller.where(account_id: account_id).first.try(:id) if seller_id.nil?
    if seller_id.nil?
      puts "SELLER_ID 不能为空,或该账户没有sellers"
      return
    end
    StockProduct.where(account_id: account_id).delete_all
    Sku.where(account_id: account_id).find_each do |sku|
      StockProduct.create({
        max:        0,
        safe_value: 0,
        activity:   0,
        actual:     0,
        product_id: sku.product_id,
        seller_id:  seller_id,
        sku_id:     sku.id,
        num_iid:    sku.num_iid,
        account_id: account_id
        })
    end
  end
end
# encoding:utf-8
desc "同步商品分流"
task :sync_products => :environment do
	product_iids = [
		'I1P04L10027C0V01', 
		'O1P04L10113C0V00',
    'O1P21L60114C0V00',
    'O1P21L60115C0V00',
    'O1P21L60116C0V00',
    'O1P21L60117C0V00'
  ]

  product_ids = []
  product_iids.each do |outer_id|
  	puts outer_id
    product = Product.find_by_outer_id outer_id
    product ||= Product.create!(
      name: outer_id,
      outer_id: outer_id,
      storage_num: outer_id
    )

    product_ids << product.id
  end

  a = [
    'A1P14L20048C0W01',
    'I1P18L50060C4V03',
    'I1P18L50061C4V04',
    'I1P18L40062C4V03',
    'I1P04L10028C0V01',
    'I1P04L10026C0V01',
    'I1P04L10027C0V01',
    'I1P04L10056C0V00',
    'I1P04L10058C0V01',
    'I1P18L50102C4V07',
    'I1P02L10105C4V04',
    'I1P04L10106C0V01',
    'I1P18L20110C4V04',
    'A1P14L20111C0W03',
    'I1P18L20109C4V03',
    'I1P18L10112C4V03',
    'I1P04L10095C0V01'
  ]

  p_ids = Product.where(outer_id: (a | product_iids)).map(&:id)
  StockProduct.where("seller_id not in (?)", [1791,1792,1793,1794]).where("product_id in (?)", p_ids).delete_all

  product_ids = p_ids

  (1791..1794).each do |id|
  	seller = Seller.find id
    seller.stock_products.delete_all
  	product_ids.each do |product_id|
      sp = seller.stock_products.create!(
        product_id: product_id,
        safe_value: 20,
        max: 99999,
        activity: 9000,
        actual: 9000
      )
    end
  end
end
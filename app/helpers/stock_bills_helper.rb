# -*- encoding : utf-8 -*-

module StockBillsHelper
  def sku_id_or_num_iid(sku)
    if sku.sku_id.present?
      "bill_products_sku_id_eq#{sku.sku_id}"
    else
      "bill_products_num_iid_eq#{sku.num_iid}"
    end
  end

  def build_product(bill,bill_product_ids)
    current_user.settings.tmp_products ||= []
    @tmp_products = current_user.settings.tmp_products.select {|x| bill_product_ids.include?(x.id.to_s)}
    @tmp_products.each {|product| bill.bill_products.build(product.marshal_dump)  }
  end

  def add_tmp_product(product)
    validate_parameter(product)
    sku = Sku.find(product["sku_id"])
    pro = sku.product
    product.merge!({:title => sku.title,:outer_id => pro.outer_id,:type => params[:controller]})
    sku_id      = product.fetch("sku_id")
    @tmp_products = (current_user.settings.tmp_products ||= [])
    @tmp_products +=  [OpenStruct.new(product.merge!({:sku_id => sku_id} ))]
    tmp_products = current_user.settings.tmp_products = new_products(@tmp_products)
    @tmp_products = specified_tmp_products(tmp_products)
  end

  def new_products(tmp_products)
    @new_products = []
    tmp_products.group_by {|product| product.type }.each do |type,products|

      tmp_product_groups = products.group_by {|i| i.sku_id}
      tmp_product_groups.each do |sku_id,collections|
        product_statis = {:sku_id => sku_id, :id => sku_id}
        collections.each do |tmp_bill_product|
          product_statis.merge!(tmp_bill_product.marshal_dump.except(:sku_id,:type)) {|x,y,z| y.to_i + z.to_i }
          product_statis.merge!({:price => tmp_bill_product.price,:title => tmp_bill_product.title,:outer_id => tmp_bill_product.outer_id,:account_id => current_account.id,:type => type})
        end
        @new_products += [OpenStruct.new(product_statis)]
      end
    end
    @new_products
  end

  def validate_parameter(product)
    sku_id      = product["sku_id"]
    number      = product["number"]
    total_price = product["total_price"]
    raise "sku_id 不能为空"       if sku_id.blank?
    raise "number 不能为空"       if number.blank?
    raise "total_price 不能为空"  if total_price.blank?
  end

  def specified_tmp_products(tmp_products)
    tmp_products.select {|x| (x.account_id == current_account.id) && (x.type == params[:controller])}
  end
end

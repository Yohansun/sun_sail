# -*- encoding : utf-8 -*-
module CustomersHelper
  def product(products,product_id)
    product = products.find {|product| product.id == product_id}
  end

  def product_with_use_days(customer,products)
    customer.transaction_histories.collect do |trade|
      (trade.product_ids & @product_ids rescue trade.product_ids).collect do |product_id|
        product = product(products,product_id)
        (product.name rescue "") << "(" <<  (product.category.use_days.to_s rescue "") << "天)"
      end.compact
    end.flatten
  end

  COUNT = 10

  def reports(*args)
    options = args.extract_options!
    options[:count] ||= COUNT
    customer = args.shift
    raise "The first Argument must be Customer instance" if customer.class.name != "Customer"
    hash = {}
    {"years" => "%Y(年)", "months" => "%Y/%m(月)","days" => "%Y/%m/%d(日)","weeks" => "%Y(第%W周)"}.each do |name,format|
      hash[name] =  customer.transaction_histories.group_by {|x| x.created.strftime(format)}.take(options[:count]).collect do |k,v|
        {priceLevels: k, visits: v.sum(&:payment),color: "#0088cc"}.to_json
      end
    end
    hash
  end
end
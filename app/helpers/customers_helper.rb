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
end
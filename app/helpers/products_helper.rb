module ProductsHelper
  def package_items(product)
    items = []
    product.packages.each do |p|
      items << [p.iid, p.number].to_s
    end

    items.join(',').delete "\""
  end
end

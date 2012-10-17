module TradesHelper
  def get_package(iid)
    product = Product.where(iid: iid).first
    return [] unless product
    product.children.map &:name
  end
end

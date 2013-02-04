module StockProductsHelper
  def sku_option(id)
    str = ''
    skus = Sku.where(product_id: id)
    skus.each do |sku|
      str += "<option value='#{sku.id}'>#{sku.name}</option>"
    end  
    str 
  end
end

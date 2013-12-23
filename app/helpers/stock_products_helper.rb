#encoding: utf-8
module StockProductsHelper
  def get_col_style(visible_cols, col_name, stock_product)
    col_style = ""

    if col_name == "storage_status" && stock_product.send(col_name) == "预警"
      col_style += 'color:red;'
    end

    if !visible_cols.include?(col_name)
      col_style += 'display:none'
    end

    col_style
  end
end
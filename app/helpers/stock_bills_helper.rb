# -*- encoding : utf-8 -*-

module StockBillsHelper
  def sku_id_or_num_iid(sku)
    if sku.sku_id.present?
      "bill_products_sku_id_eq#{sku.sku_id}"
    else
      "bill_products_num_iid_eq#{sku.num_iid}"
    end
  end
end

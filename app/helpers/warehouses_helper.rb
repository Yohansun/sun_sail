#encoding: utf-8
module WarehousesHelper
  #仓库管理 所有仓库详细页面 默认tabs
  # 如果要在仓库详细页面中添加导航,请在下面添加
  CHILD_TABS = Hash.new {|k,warehouse|
            {
              "入库单"  => "/warehouses/#{warehouse}/stock_in_bills",
              "出库单"  => "/warehouses/#{warehouse}/stock_out_bills",
              "退货单"  => "/warehouses/#{warehouse}/refund_products",
              "所有进销" => "/warehouses/#{warehouse}/stock_bills",
              "库存查询" => "/warehouses/#{warehouse}/stocks"
            }
          }

  def one_tabs
    {"所有仓库"  => warehouses_path,"总库存"  => "/stocks"}
  end

  def stocks_path_adapter
    warehouse_count = current_account.sellers.count
    if warehouse_count > 1
      if params[:warehouse_id]
         "/warehouses/#{params[:warehouse_id]}/stocks"
      else
        current_user.seller_id.blank? ? stocks_path : warehouse_stocks_path(current_user.seller_id)
      end
    else
      warehouse = current_account.sellers.first
      "/warehouses/#{warehouse.id}/stocks"
    end
  end

  def warehouse_tabs(warehouse)
    warehouse_count = current_account.sellers.count
    two_tabs_controllers = params[:controller] =~ /stock_in_bills|refund_products|stock_out_bills|stock_bills|stocks/
    if warehouse_count > 1
      params[:warehouse_id].blank? ? one_tabs : CHILD_TABS[warehouse.id]
    elsif warehouse_count == 1
      warehouse ||= current_account.sellers.first
      CHILD_TABS[warehouse.id]
    else
      {}
    end
  end
end

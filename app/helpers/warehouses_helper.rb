#encoding: utf-8
module WarehousesHelper
  #仓库管理 所有仓库详细页面 默认tabs
  # 如果要在仓库详细页面中添加导航,请在下面添加
  CHILD_TABS = Hash.new {|k,warehouse|
            {
              "入库单"  => "/warehouses/#{warehouse}/stock_in_bills",
              "出库单"  => "/warehouses/#{warehouse}/stock_out_bills",
              "所有进销" => "/warehouses/#{warehouse}/stock_bills",
              "库存查询" => "/warehouses/#{warehouse}/stocks",
              "库存导入" => "/warehouses/#{warehouse}/stock_csv_files/new"
            }
          }

  def one_tabs
    {"所有仓库"  => warehouses_path,"库存查询"  => "/stocks"}
  end

  def warehouse_tabs(warehouse)
    warehouse_count = current_account.sellers.count
    two_tabs_controllers = params[:controller] =~ /stock_in_bills|stock_out_bills|stock_bills|stocks/
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

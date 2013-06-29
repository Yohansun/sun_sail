#encoding: utf-8
module WarehousesHelper
  #仓库管理 所有仓库详细页面 默认tabs
  # 如果要在仓库详细页面中添加导航,请在下面添加
  TWO_TABS = Hash.new {|k,warehouse|
            {
              "入库单"  => "/warehouses/#{warehouse}/stock_in_bills",
              "出库单"  => "/warehouses/#{warehouse}/stock_out_bills",
              "所有进销" => "/warehouses/#{warehouse}/stock_bills"
            }
          }

  DYNAMIC_TABS = Hash.new {|x,warehouse| {"库存查询"  => "/warehouses/#{warehouse}/stocks"} }
  
  def one_tabs(warehouse)
    {"所有仓库"  => warehouses_path}.merge(DYNAMIC_TABS[warehouse])
  end

  def warehouse_tabs(warehouse)
    warehouse_count = current_account.sellers.count
    two_tabs_controllers = params[:controller] =~ /stock_in_bills|stock_out_bills|stock_bills/
    if warehouse_count > 1
      !two_tabs_controllers ? one_tabs(warehouse.id) : TWO_TABS[warehouse.id]
    elsif warehouse_count == 1
      TWO_TABS[warehouse.id].merge(DYNAMIC_TABS[warehouse.id])
    else
      {}
    end
  end
end

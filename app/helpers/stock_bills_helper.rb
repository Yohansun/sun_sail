#encoding: utf-8
module StockBillsHelper
  def stock_types
    if current_account.enabled_third_party_stock?
      if params[:controller] == "stock_in_bills"
        [["待审核", "CREATED"],["已审核待同步","CHECKED"],["同步中","SYNCKING"], ["已同步待入库", "SYNCKED"],["同步失败待同步", "SYNCK_FAILED"], ["已关闭", "CLOSED"],["已入库", "STOCKED"],["撤销同步成功", "CANCELD_OK"],["撤销同步中", "CANCELING"],["撤销同步失败","CANCELD_FAILED"]]
      else
        [["待审核", "CREATED"],["已审核待同步","CHECKED"],["同步中","SYNCKING"], ["已同步待出库", "SYNCKED"],["同步失败待同步", "SYNCK_FAILED"], ["已关闭", "CLOSED"],["已出库", "STOCKED"],["撤销同步成功", "CANCELD_OK"],["撤销同步中", "CANCELING"],["撤销同步失败","CANCELD_FAILED"]]
      end
    else
      if params[:controller] == "stock_in_bills"
        [["待审核","CREATED"], ["已审核待入库","SYNCKED"], ["已入库","STOCKED"]]
      else
        [["待审核","CREATED"], ["已审核待出库","SYNCKED"], ["已出库","STOCKED"]]
      end
    end
  end
end
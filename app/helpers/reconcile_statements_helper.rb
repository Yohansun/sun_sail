# -*- encoding : utf-8 -*-
module ReconcileStatementsHelper

  def get_account_content
    if current_account.settings.enable_module_reconcile_statements_for_magicd == true 
      @brand_name = "多乐士确认结算"
      @status_name = "多乐士未结算"
      @statuses_select = [["请选择",""],["未结算","unprocessed"],["多乐士已结算，等待运营商结算","processed"],["已结算","audited"]]
      @seller_statuses_select = [["请选择",""],["未结算","unprocessed"],["多乐士已结算,等待经销商结算","processed"],["已结算","audited"]]
    else 
      @brand_name = "品牌确认结算"
      @status_name ="品牌未确认结算"
      @statuses_select = [["请选择",""],["运营商未结算","unaudited"],["品牌商未结算","unprocessed"],["运营商已结算","audited"]]
      @seller_statuses_select = [["请选择",""],["经销商未结算","unaudited"],["品牌商未结算","unprocessed"],["经销商已结算","audited"]]
    end
    if current_account.settings.enable_module_reconcile_statements_for_kele == true 
      @store_audit_num = "实际支付金额"
    else
      @store_audit_num = "结算金额"
    end
  end

end
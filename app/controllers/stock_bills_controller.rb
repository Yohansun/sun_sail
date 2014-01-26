# -*- encoding : utf-8 -*-
class StockBillsController < ApplicationController
  before_filter :set_warehouse, :except => [:update_status, :get_products]
  before_filter :authorize, :except => :update_status
  before_filter :fetch_bills, :except => [:update_status, :get_products]
  skip_before_filter :authenticate_user!, :only => :update_status
  skip_before_filter :verify_authenticity_token, :only => :update_status

  def index
    parse_params
    @search = @bills.search(params[:search]).desc(:created_at)
    @count = @search.map(&:bill_products).count
    @bills = @search.page(params[:page]).per(params[:number])
    @all_cols = current_account.settings.stock_bill_cols
    @visible_cols = current_account.settings.stock_bill_visible_cols

    cur_page = params[:page].to_i
    @start_no = cur_page > 0 ? (cur_page - 1) * (params[:number] || @bills.default_per_page).to_i + 1 : 1
  end

  def fetch_bills
    if current_account.settings.enable_module_third_party_stock == 1
      @bills = StockBill.where(account_id: current_account.id,:seller_id => @warehouse.id, :confirm_stocked_at.ne => nil)
    else
      @bills = StockBill.where(account_id: current_account.id,:seller_id => @warehouse.id, :stocked_at.ne => nil)
    end
  end

  def parse_params
    search = params[:search] ||= {}
    params[:search][:_id_in] = params[:export_ids].split(',') if params[:export_ids].present?
  end

  def get_products
    @products = current_account.skus.includes(:product).where("products.name like ?", "%#{params[:tid].strip}%") if params[:tid]
    @products = current_account.skus.where(id: params[:sku_id]) if params[:sku_id]
    respond_to do |format|
      format.json { render partial: "partials/products.json"}
    end
  end

  def update_status
    if params[:xml].present?
      response = Hash.from_xml(params[:xml]).as_json
      data = response['DATA']
      if data
        order = data['ORDER']
        tid = order['ORDERID']
        unless StockBill.where(tid: tid).exists?
          render :text => "<DATA><RET_CODE>FAIL</RET_CODE><RET_MESSAGE>ORDER_NOT_FOUND</RET_MESSAGE></DATA>"
          return
        end
        stock_bill = StockBill.where(tid: tid, :status.ne => 'CLOSED').first
        unless stock_bill
          render :text => "<DATA><RET_CODE>FAIL</RET_CODE><RET_MESSAGE>ORDER_STATUS_UNCHANGEABLE</RET_MESSAGE></DATA>"
          return
        end
        account = stock_bill.account
        if params[:login] ==  account.settings.stock_login && params[:passwd] ==  account.settings.stock_passwd
          trade = stock_bill.trade
          if trade
            if order['OPTTYPE'] == 'OrderShip'
              is_first_set = trade.logistic_waybill.blank?
              logistic = Logistic.find_by_code(order['EXPRESSCODE'])
              trade.update_attributes!(logistic_waybill: order['SHIPMENTID'],logistic_name: logistic.try(:name),logistic_code: order['EXPRESSCODE'],logistic_id: logistic.try(:id),service_logistic_id: trade.get_third_party_logistic_id(logistic.try(:id)))

              if account && account.settings && account.settings.auto_settings
                auto_settings = account.settings.auto_settings
                if auto_settings['auto_deliver'] && auto_settings["deliver_condition"] == "has_logistic_waybill_trade" && is_first_set
                  trade.auto_deliver!
                end
              end
            elsif order['OPTTYPE'] == 'OrderSign'
              stock_bill.operation_logs.create(operated_at: Time.now, operation: '签收')
            elsif order['OPTTYPE'] == 'OrderRefuse'
              stock_bill.operation_logs.create(operated_at: Time.now, operation: '拒收')
            end
          end

          if order['OPTTYPE'] == 'OrderShip'
            if (stock_bill._type == "StockInBill" && stock_bill.sync_stock ) || (stock_bill._type == "StockOutBill" && stock_bill.decrease_actual)
              stock_bill.do_stock
              stock_bill.operation_logs.create(operated_at: Time.now, operation: '确认成功')
            end
          elsif order['OPTTYPE'] == 'OrderSign'
            stock_bill.operation_logs.create(operated_at: Time.now, operation: '签收')
          elsif order['OPTTYPE'] == 'OrderRefuse'
            stock_bill.operation_logs.create(operated_at: Time.now, operation: '拒收')
          end
          render :text => "<DATA><RET_CODE>SUCC</RET_CODE><RET_MESSAGE>OK</RET_MESSAGE></DATA>"
        else
          render :text => "<DATA><RET_CODE>FAIL</RET_CODE><RET_MESSAGE>AUTHENTICATION_FAILED</RET_MESSAGE></DATA>"
        end
      else
        render :text => "<DATA><RET_CODE>FAIL</RET_CODE><RET_MESSAGE>EMPTY_DATA</RET_MESSAGE></DATA>"
      end
    else
      render :text => "<DATA><RET_CODE>FAIL</RET_CODE><RET_MESSAGE>EMPTY_XML</RET_MESSAGE></DATA>"
    end
  end

  private
  def set_warehouse
    @warehouse = Seller.find(params[:warehouse_id])
  end
end

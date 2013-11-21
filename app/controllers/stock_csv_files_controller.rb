# -*- encoding : utf-8 -*-

class StockCsvFilesController < ApplicationController
  before_filter :set_warehouse

  def new
    @csv_file = @warehouse_csvs.last
    if @csv_file && @csv_file.stock_in_bill_id.blank?
      redirect_to :action => "show", :id => @csv_file.id
    else
      @csv_file = StockCsvFile.new
    end
  end

  def create
    @csv_file = StockCsvFile.new
    if (@warehouse_csvs.last.used == true rescue false) || @warehouse_csvs.last == nil
      if params[:stock_csv_file].present? && params[:stock_csv_file][:path].present?
        @csv_file = StockCsvFile.create(path: params[:stock_csv_file][:path], upload_user_id: current_user.id, seller_id: @warehouse.id)
        flash.now[:notice] = @csv_file.errors.full_messages.join(",") if @csv_file.errors.any?
      else
        flash.now[:notice] = "未上传文件"
      end
    else
      if @warehouse_csvs.last && @warehouse_csvs.last.stock_in_bill_id.blank?
        redirect_to :action => "show", :id => @csv_file.id
      else
        flash.now[:notice] = "导入失败，请先检查确认没有未审核的期初入库单"
      end
    end
    flash.now[:notice].present? ? (render :new) : (redirect_to :action => "show", :id => @csv_file.id)
  end

  def show
    @csv_file = @warehouse_csvs.find(params[:id]) rescue nil
    if @csv_file && @csv_file.stock_in_bill_id.blank?
      csv_mapper = @csv_file.verify_stock_csv_file(current_account)
      if csv_mapper.present?
        @csv_header = csv_mapper.slice!(0)
        @csv_info_count = csv_mapper.count
        @csv_info = Kaminari.paginate_array(csv_mapper).page(params[:page]).per(20)
      else
        flash[:notice] = "文件数据格式有误，请检查 1.文件必须与导出库存表格格式相同 2.文件编码为uft-8格式 3.文件没有空行 4.表格中库存商品均存在"
        redirect_to :action => "new"
      end
    else
      redirect_to "/warehouses/#{params[:warehouse_id]}/stocks"
    end
  end

  def update
    @csv_file = @warehouse_csvs.find(params[:id])
    @csv_file.create_stock_in_bill(current_account)
    redirect_to "/warehouses/#{params[:warehouse_id]}/stocks"
  end

  def destroy
    @csv_file = @warehouse_csvs.find(params[:id]).delete
    redirect_to "/warehouses/#{params[:warehouse_id]}/stocks"
  end

  private

  def set_warehouse
    @warehouse = Seller.find(params[:warehouse_id])
    @warehouse_csvs = @warehouse.stock_csv_files
  end

end
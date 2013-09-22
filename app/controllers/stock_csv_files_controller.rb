# -*- encoding : utf-8 -*-

class StockCsvFilesController < ApplicationController
  before_filter :set_warehouse

  def new
    @csv_file = StockCsvFile.where(seller_id: @warehouse.id).last
    if @csv_file && @csv_file.stock_in_bill_id.blank?
      redirect_to :action => "show", :id => @csv_file.id
    else
      @csv_file = StockCsvFile.new
    end
  end

  def create
    @csv_file = StockCsvFile.new
    if (StockCsvFile.last.used == true rescue false) || StockCsvFile.last == nil
      if params[:stock_csv_file].present? && params[:stock_csv_file][:path].present?
        @csv_file = StockCsvFile.create(path: params[:stock_csv_file][:path], upload_user_id: current_user.id, seller_id: @warehouse.id)
        flash[:notice] = @csv_file.errors.full_messages.join(",") if @csv_file.errors.any?
      else
        flash[:notice] = "未上传文件"
      end
    else
      flash[:notice] = "导入失败，请先检查确认没有未审核的期初入库单"
    end

    flash[:notice].present? ? (render :new) : (redirect_to :action => "show", :id => @csv_file.id)
  end

  def show
    @csv_file = StockCsvFile.where(seller_id: @warehouse.id).find(params[:id]) rescue nil
    if @csv_file && @csv_file.stock_in_bill_id.blank?
      csv_mapper = CsvMapper.import(@csv_file.path.current_path) do
        start_at_row 1
        [id, sku_id, sku_name, num_iid, category, forecast, activity, actual, safe_value, storage_status]
      end
      @csv_header = csv_mapper.slice!(0)
      @csv_info_count = csv_mapper.count
      @csv_info = Kaminari.paginate_array(csv_mapper).page(params[:page]).per(20)
    else
      redirect_to "/stocks"
    end
  end

  def update
    @csv_file = StockCsvFile.where(seller_id: @warehouse.id).find(params[:id])
    @csv_file.create_stock_in_bill(current_account)
    redirect_to "/stocks"
  end

  def destroy
    @csv_file = StockCsvFile.where(seller_id: @warehouse.id).find(params[:id]).delete
    redirect_to "/stocks"
  end

  private

  def set_warehouse
    @warehouse = Seller.find(params[:warehouse_id])
  end

end
# -*- encoding : utf-8 -*-
class AreasController < BaseController

	  
	def remap_sellers
    # if request.post?
    #   data = params[:data]
    #   lines = data.split("\n").map { |e| e.strip }
    #   if lines[0].split("\t").size == 4
    #     sep = "\t"
    #   elsif lines[0].split(" ").size == 4
    #     sep = " "
    #   else
    #     sep = ","
    #   end
    #   result = 0
    #   lines.each do |line|
    #     row = line.split(sep).map { |e| e.strip }
    #     area1 = Area.find_by_name(row[0])
    #     area2 = area1.children.find_by_name(row[1])
    #     area3 = area2.children.find_by_name(row[2])
    #     if area3
    #       seller = Seller.find_by_name(row[3])
    #       unless area3.sellers.exists?(seller) && area3.seller_id == seller.id
    #         area3.sellers << seller
    #         area3.seller_id = seller.id
    #         area3.save
    #         result += 1
    #       end
    #     end
    #   end
    #   flash[:notice] = "已导入 #{result} 条数据"
    #   redirect_to :action => 'remap_sellers'
    # end
  end

	#TODO 导出表中其他表的数据依赖关系不满足,依赖建立后释放模板
	def export
    @areas = Area.where "parent_id IS NULL"
  end

  def update
    @area = Area.find params[:id]
    if @area.update_attributes params[:area]
      redirect_to areas_url
    else
      render :edit
    end
  end

	def create
    @area = Area.new params[:area]
    if @area.save
      redirect_to areas_url
    else
      render :new
    end
  end

  def autocomplete
  	areas = Area.select("name,id").where("name like ?", "%#{params[:q]}%")
  	respond_to do |format|
  		format.json {render :json => areas}
  	end	
 	end 	

 	def area_search
 		ids = params[:q].split(",") || ""
 		@areas = Area.where("id in (?)", ids).paginate(:page => params[:page], :per_page => 50)
 		render :index
 	end	

	protected
  def collection
    @areas ||= end_of_association_chain.paginate(:page => params[:page], :per_page => 50).order("pinyin")
    if request.get? && params[:parent_id]
      @current_area = Area.find(params[:parent_id])
      @areas = @areas.where( :parent_id => params[:parent_id] )
    else
    	#TODO 释放权限验证
      # if current_admin.super_admin?
      #   @areas = @areas.where("parent_id is null")
      # else
      #   @areas = current_admin.root_areas
      # end
      @areas = @areas.where("parent_id is null")
    end
  end
end
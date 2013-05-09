class SkusController < ApplicationController
  before_filter :set_product
  # GET /skus
  # GET /skus.json
  def index
    @skus = @product.skus.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @skus }
    end
  end

  # GET /skus/1
  # GET /skus/1.json
  def show
    @sku = Sku.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: [@product,@sku] }
    end
  end

  # GET /skus/new
  # GET /skus/new.json
  def new
    @sku = Sku.new
    category = @product.category
    category.category_properties.each{|cp|
      @sku.sku_properties.build(category_property:cp)
    }

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: [@product,@sku] }
    end
  end

  # GET /skus/1/edit
  def edit
    @sku = Sku.find(params[:id])
  end

  # POST /skus
  # POST /skus.json
  def create
    @sku = @product.skus.new(params[:sku])

    respond_to do |format|
      if @sku.save
        format.html { redirect_to [@product,@sku], notice: 'Sku was successfully created.' }
        format.json { render json: @sku, status: :created, location: @sku }
      else
        format.html { render action: "new" }
        format.json { render json: @sku.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /skus/1
  # PUT /skus/1.json
  def update
    @sku = Sku.find(params[:id])

    respond_to do |format|
      if @sku.update_attributes(params[:sku])
        format.html { redirect_to [@product,@sku], notice: 'Sku was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sku.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /skus/1
  # DELETE /skus/1.json
  def destroy
    @sku = Sku.find(params[:id])
    @sku.destroy

    respond_to do |format|
      format.html { redirect_to [@product, :skus] }
      format.json { head :no_content }
    end
  end


:private


  def set_product
    @product = Product.find(params[:product_id])
  end


end

class TradeSearchesController < ApplicationController

  layout 'management'

  # GET /trade_searches
  # GET /trade_searches.json
  def index
    @trade_searches = TradeSearch.where(account_id:current_account.id).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: TradeSearch.where(account_id:current_account.id).all }
    end
  end

  # GET /trade_searches/1
  # GET /trade_searches/1.json
  def show
    @trade_search = TradeSearch.where(account_id:current_account.id).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trade_search }
    end
  end

  # GET /trade_searches/new
  # GET /trade_searches/new.json
  def new
    @trade_search = TradeSearch.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trade_search }
    end
  end

  # GET /trade_searches/1/edit
  def edit
    @trade_search = TradeSearch.where(account_id:current_account.id).find(params[:id])
    render :partial=>"form" if request.xhr?

  end

  # POST /trade_searches
  # POST /trade_searches.json
  def create
    @trade_search = TradeSearch.new(params[:trade_search])
    @trade_search.account_id = current_account.id
    @trade_search.show_in_tabs = false
    @trade_search.enabled = true
    respond_to do |format|
      if @trade_search.save
        format.html { redirect_to @trade_search, notice: 'Trade search was successfully created.' }
        format.json { render json: @trade_search, status: :created, location: @trade_search }
        format.js { render json: @trade_search, status: :created, location: @trade_search }

      else
        format.html { render action: "new" }
        format.json { render json: @trade_search.errors, status: :unprocessable_entity }
        format.js { render json: @trade_search.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /trade_searches/1
  # PUT /trade_searches/1.json
  def update
    @trade_search = TradeSearch.where(account_id:current_account.id).find(params[:id])

    respond_to do |format|
      if @trade_search.update_attributes(params[:trade_search])
        format.html { redirect_to @trade_search, notice: 'Trade search was successfully updated.' }
        format.json { head :no_content }
        format.js { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @trade_search.errors, status: :unprocessable_entity }
        format.js { render json: @trade_search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trade_searches/1
  # DELETE /trade_searches/1.json
  def destroy
    @trade_search = TradeSearch.where(account_id:current_account.id).find(params[:id])
    @trade_search.destroy

    respond_to do |format|
      format.html { redirect_to trade_searches_url }
      format.json { head :no_content }
    end
  end


  # BULK operation for multi-records
  def operations
    send(params[:ac])
  end


  def deletes
    @ids = params[:ids].split(",")
    TradeSearch.destroy_all(account_id:current_account.id,:id.in=>@ids)
    redirect_to :trade_searches
  end
end

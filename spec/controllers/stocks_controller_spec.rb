require 'spec_helper'

describe StocksController do
  login_admin

  let(:stock) { create(:stock_product,:product => create(:product),:account => current_account) }
  before(:each) { stock }

  def valid_attributes
    {  }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CustomersController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all stocks as @stock_products" do
      get :index,{}, valid_session
      assigns(:stock_products).to_a.should eq([stock])
    end
  end
end

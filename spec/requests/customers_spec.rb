#encoding: utf-8
require 'spec_helper'

describe "Customers" do
  login_admin
  
  describe "GET /customers" do
    it "works! (now write some real specs)" do
      get "/customers"
      expect(response).to render_template(:index)
      response.status.should be(200)
    end
  end
  describe "GET /customers/potential" do
    it "works! (now write some real specs)" do
      get "/customers/potential"
      expect(response).to render_template(:index)
      response.status.should be(200)
    end
  end
  describe "GET /customers/paid" do
    it "works! (now write some real specs)" do
      get "/customers/paid"
      expect(response).to render_template(:index)
      response.status.should be(200)
    end
  end
  describe "GET /customers/around" do
    it "works! (now write some real specs)" do
      get "/customers/around"
      expect(response).to render_template(:around)
      response.status.should be(200)
    end
  end
  describe "GET /customers/1" do
    it "works! (now write some real specs)" do
      customer = create(:customer,:name => 'Matsumoto',:account_id => current_account.id)
      customer.transaction_histories.create(:tid => "1234567890p",:created => Time.now)
      get customer_path(customer)
      response.status.should be(200)
    end
  end
  describe "GET /customers/send_messages" do
    it "works! (now write some real specs)" do
      customer = create(:customer,:name => 'Matsumoto',:account_id => current_account.id)
      customer.transaction_histories.create(:tid => "1234567890p",:created => Time.now,:product_ids => [1])
      get send_messages_customers_path(:product_ids => "1,2,3")
      response.status.should be(200)
    end
  end
  describe "POST /customers/invoice_messages" do
    before do
      customer = create(:customer,:name => 'Matsumoto',:account_id => current_account.id)
      customer.transaction_histories.create(:tid => "1234567890p",:created => Time.now,:product_ids => [1])
    end
    it "works! (now write some real specs)" do
      post invoice_messages_customers_path(:product_ids => "1,2,3")
      flash[:error].should eq("发送失败")
      expect(response).to render_template(:send_messages)
      response.status.should be(200)
    end
    
    it "work" do
      post invoice_messages_customers_path(:product_ids => "1,2,3",:message => {:recipients => "15848792001",:send_type => "sms",:title => "test",:content => "hello world!"})
      expect(response).to redirect_to(send_messages_customers_path)
      flash[:notice].should eq("发送中...")
      response.status.should be(302)
    end
  end
  
  describe "GET /customers/get_recipients" do
    it "works! (now write some real specs)" do
      get get_recipients_customers_path(:product_ids => "1,2,3",:format => :js)
      response.status.should be(200)
    end
  end
end

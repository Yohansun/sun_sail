# encoding: utf-8
require 'spec_helper'

describe StockBillsHelper do
  let(:current_user) { FactoryGirl.create(:user, username: 'user', password: '123456')}
  let(:current_account) {FactoryGirl.create(:account,:name => "dulux",:key => "dulux")}
  let(:sku) { FactoryGirl.create(:sku,:sku_id => 20,:product => FactoryGirl.create(:product,:outer_id => 1)) }
  let(:sku_2) { FactoryGirl.create(:sku,:sku_id => 10,:product => FactoryGirl.create(:product,:outer_id => 2)) }
  let(:tmp_products) do
    product_1 = {:sku_id => 20, :number => 1, :total_price => 1,:title => sku.title,:outer_id => "1",:type => "stock_in_bills" }
    product_2 = {:sku_id => 20, :number => 2, :total_price => 3,:title => sku.title,:outer_id => "1",:type => "stock_in_bills" }
    product_3 = {:sku_id => 10, :number => 1, :total_price => 1,:title => sku_2.title,:outer_id => "2",:type => "stock_out_bills" }
    product_4 = {:sku_id => 10, :number => 3, :total_price => 4,:title => sku_2.title,:outer_id => "2",:type => "stock_out_bills" }
    [product_1,product_2,product_3,product_4].collect {|product| OpenStruct.new(product) }
  end
  
  before(:each) do
    view.stub(:current_user) {current_user}
    view.stub(:current_account) {current_account}
  end
  
  describe "#sku_id_or_num_iid" do
     it "returns the specified variable" do
       sku_1 = stub_model(Sku, :sku_id => 1)
       sku_2 = stub_model(Sku, :num_iid => 1)
       helper.sku_id_or_num_iid(sku_1).should eql("bill_products_sku_id_eq1")
       helper.sku_id_or_num_iid(sku_2).should eql("bill_products_num_iid_eq1")
     end
   end
   
   describe "#build_product" do
     it "build bill_products from stock_bill" do
       bill = FactoryGirl.build(:stock_in_bill,:stock_type => "IIR")
       helper.build_product(bill,[1,2,3]).should == []
     end
   end
   
   describe "#add_tmp_product" do
     it "should add tmp product" do
       view.stub(:params) { {:controller => "stock_in_bill"} }
       product = {"sku_id" => 20, "number" => 1, "total_price" => 1}
       tmp_marshal_dump = product.merge({
         "id" => 20,
         "price" => nil,
         "account_id" => current_account.id,
         "title" => sku.title,
         "outer_id" => "1",
         "type" => "stock_in_bill"
       })
       products = helper.add_tmp_product(product)
       products.map(&:marshal_dump).each do |hash|
         hash.should == tmp_marshal_dump.symbolize_keys
       end
     end
   end
   
   describe "#new_products" do
     it "should new products" do
       helper.new_products(tmp_products).each do |product|
         product.marshal_dump.should == {:id => 20, :account_id => current_account.id,:price => nil,:sku_id => 20, :number => 3, :total_price => 4,:title => sku.title,:outer_id => "1",:type => "stock_in_bills" } if product.type == "stock_in_bills"
         product.marshal_dump.should == {:id => 10, :account_id => current_account.id,:price => nil,:sku_id => 10, :number => 4, :total_price => 5,:title => sku.title,:outer_id => "2",:type => "stock_out_bills" } if product.type == "stock_out_bills"
       end
     end
   end
   
   describe "#validate_parameter" do
     it "should validate parameter" do
       product = {}
       expect { helper.validate_parameter(product) }.to raise_error("sku_id 不能为空")
       product.merge!("sku_id" => 1)
       expect { helper.validate_parameter(product) }.to raise_error("number 不能为空")
       product.merge!("number" => 1)
       expect { helper.validate_parameter(product) }.to raise_error("total_price 不能为空")
       product.merge!("total_price" => 1)
       expect { helper.validate_parameter(product) }.to_not raise_error
     end
   end
   
   describe "#specified_tmp_products" do
     it "should return specified tmp_products in stock_in_bills controller" do
       helper.new_products(tmp_products)
       view.stub(:params) { {:controller => "stock_in_bill"} }
       helper.specified_tmp_products(tmp_products).each do |product|
         product.marshal_dump.should == {:id => 20, :account_id => current_account.id,:price => nil,:sku_id => 20, :number => 3, :total_price => 4,:title => sku.title,:outer_id => "1",:type => "stock_in_bills" }
       end
       view.stub(:params) { {:controller => "stock_out_bill"} }
       helper.specified_tmp_products(tmp_products).each do |product|
         product.marshal_dump.should == {:id => 10, :account_id => current_account.id,:price => nil,:sku_id => 10, :number => 4, :total_price => 5,:title => sku.title,:outer_id => "2",:type => "stock_out_bills" }
       end
     end
   end
end
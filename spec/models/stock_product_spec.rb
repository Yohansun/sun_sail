# == Schema Information
#
# Table name: stock_products
#
#  id         :integer(4)      not null, primary key
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  max        :integer(4)      default(0)
#  safe_value :integer(4)      default(0)
#  activity   :integer(4)      default(0)
#  actual     :integer(4)      default(0)
#  product_id :integer(4)
#  seller_id  :integer(4)
#

require 'spec_helper'

describe StockProduct do
  describe "update activity stock" do
    before(:each) do
      @account = create(:account)
      @sku = create(:sku,:account_id => @account.id)
      @stock_product = create(:stock_product,:activity => 1,:actual => 2,:account_id => @account.id,:product_id => @sku.product_id,:sku_id => @sku.id)
    end

    it "activity and actual should be ++1" do
      @stock_product.update_activity_stock(2)
      @stock_product.activity.should == 2.0
      @stock_product.actual.should   == 3.0
    end

    it "activity and actual should be --1" do
      @stock_product.update_activity_stock(0)
      @stock_product.activity.should == 0.0
      @stock_product.actual.should   == 1.0
    end

    it "should be create stock_in_bill and stock_in_bills.number.should eq 1" do
      @stock_product.update_activity_stock(2).should == true
      stock_in_bill = StockInBill.desc(:id).first
      @bill_products = stock_in_bill.bill_products
      @bill_products.count.should == 1
      @bill_product = @bill_products.first
      @bill_product.number.should == 1
      @bill_product.real_number.should == 1
      @bill_product.sku.should eq(@sku)
      stock_in_bill.stock_type.should == "IVIRTUAL"
    end

    it "should be create stock_in_bill and stock_out_bills.number.should eq 1" do
      @stock_product.update_activity_stock(0).should == true
      stock_out_bill = StockOutBill.desc(:id).first
      @bill_products = stock_out_bill.bill_products
      @bill_products.count.should == 1
      @bill_product = @bill_products.first
      @bill_product.number.should == 1
      @bill_product.real_number.should == 1
      @bill_product.sku.should eq(@sku)
      stock_out_bill.stock_type.should == "OVIRTUAL"
    end

    it "update_activity_stock fail should not be create StockProduct" do
      @stock_product.account_id = nil
      @stock_product.save(:validate => false)
      @stock_product.update_activity_stock(2).should == false
      @stock_product.reload.activity.should == 1
      StockInBill.count.should == 0
    end

    # it "update_activity_stock fail should not be create StockBill" do
    #   StockInBill.any_instance.stub(:create!).and_return(StockInBill.new)
    #   @stock_product.update_activity_stock(2)
    #   @stock_product.reload.activity.should == 1
    #   StockInBill.count.should == 0
    # end
  end
end
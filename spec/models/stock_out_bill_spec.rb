require 'spec_helper'

describe StockOutBill do
  [:checked, :syncking, :syncked, :synck_failed,
    :stocked, :closed, :canceling, :canceld_ok,
    :canceld_failed].each do |s_name|
    it "should #{s_name}" do
      test_bill_status("stock_out_bill", s_name)
    end
  end
end

require 'spec_helper'

describe Customer do

  let(:customer) { create(:customer, :name => "Bob") }
  let(:transaction_history_1) { customer.transaction_histories.create(:status => "TRADE_FINISHED",:payment => 200,:tid => "1234567890a",:created => 3.days.from_now) }
  let(:transaction_history_2) { customer.transaction_histories.create(:status => "WAIT_SELLER_SEND_GOODS",:payment => 300,:tid => "1234567890a",:created => 4.days.from_now) }
  let(:transaction_history_3) { customer.transaction_histories.create(:status => "WAIT_SELLER_SEND_GOODS",:payment => 500,:tid => "1234567890a",:created => 5.days.from_now) }

  before do
    customer && transaction_history_1 && transaction_history_2 && transaction_history_3
  end

  it "#the_first" do
    customer.the_first.should == transaction_history_3
    transaction_history_3.update_attribute(:created,2.days.from_now)
    customer.the_first.should == transaction_history_2
  end

  it "#orders_price" do
    customer.orders_price.should == 1000.0
  end

  it "#turnover" do
    customer.turnover.should == 200.0
  end
end

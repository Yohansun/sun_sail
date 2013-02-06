require "spec_helper"

describe "trade has seller" do
  before do
    @taobao_trade = TaobaoTrade.new
    TradeDecorator.decorate(@taobao_trade).stub(:pay_time).and_return(Time.now)
    TradeDecorator.decorate(@taobao_trade).stub(:seller_id).and_return(1)
  end

  subject { TradeSplitter.new(@taobao_trade).split! }

  it { should == false }
end

describe "trade not pay yet" do
  before do
    @taobao_trade = TaobaoTrade.new
    TradeDecorator.decorate(@taobao_trade).stub(:pay_time).and_return(nil)
    TradeDecorator.decorate(@taobao_trade).stub(:seller_id).and_return(nil)
  end

  subject { TradeSplitter.new(@taobao_trade).split! }

  it { should == false }
end
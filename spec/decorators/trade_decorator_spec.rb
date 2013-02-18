require 'spec_helper'

describe TradeDecorator do
  describe "Taobaotrade" do
    context '#post_fee, point_fee, seller_discount, total_fee, sum_fee' do
      before do 
        trade = create(:taobao_trade, post_fee: 20, point_fee: 20, payment: 2000, total_fee: 3000, promotion_fee: 100)
        trade.stub(:orders_total_price).and_return(1500)
        @decorator = TradeDecorator.new(trade)
      end
      it { @decorator.post_fee.should == 20 }
      it { @decorator.point_fee.should == 20 }
      it { @decorator.total_fee.should == 2000 }
      it { @decorator.sum_fee.should == 1500 }
      it { @decorator.seller_discount.should == 100 }
    end
  end

  describe "TaobaoPurchaseOrder" do
    context '#post_fee, distributor_payment, total_fee, sum_fee' do
      before do 
        trade = create(:taobao_purchase_order, distributor_payment: 150, post_fee: 20)
        trade.stub(:orders_total_fee).and_return(1000)
        @decorator = TradeDecorator.new(trade)
      end
      it { @decorator.post_fee.should == 20 }
      it { @decorator.sum_fee.should == 1000 }
      it { @decorator.total_fee.should == 1020 }
      it { @decorator.distributor_payment.should == 150 }
    end
  end

  describe "JingdongTrade" do
    context '#post_fee, seller_discount, total_fee, sum_fee' do
      before do 
        @decorator = TradeDecorator.new(build(:jingdong_trade, freight_price: 20, order_seller_price: 1000, seller_discount: 200))
        @decorator_with_zero_freight_price = TradeDecorator.new(build(:jingdong_trade, order_seller_price: 1000, seller_discount: 200))
      end
      it { @decorator.post_fee.should == 20 }
      it { @decorator.total_fee.should == 1000 }
      it { @decorator.sum_fee.should == 820 }
      it { @decorator.seller_discount.should == 200 }
      it { @decorator_with_zero_freight_price.post_fee.should == 0 }
      it { @decorator_with_zero_freight_price.sum_fee.should == 800 }
    end
  end
end

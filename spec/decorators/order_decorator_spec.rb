require 'spec_helper'

describe OrderDecorator do

  describe "TaobaoOrder" do
    context '#price,num' do
      before do 
        order = build(:taobao_order, price: 2050, num: 3)
        order.stub(:promotion_discount_fee).and_return(150)
        @decorator = TradeDecorator.new(order)
      end
      it { @decorator.price.should == 2000 }
      it { @decorator.num.should == 3 }
    end
  end

  describe "TaobaoSubPurchaseOrder" do
    context '#price,num' do
      before do 
         @decorator = OrderDecorator.new(build(:taobao_sub_purchase_order, auction_price: 100, num: 2))
      end
      it { @decorator.price.should == 100 }
      it { @decorator.num.should == 2 }
    end
  end

  describe "JingdongOrder" do
    context '#price,num' do
      before do 
         @decorator = OrderDecorator.new(build(:jingdong_order, jd_price: 20, item_total: 1))
      end
      it { @decorator.price.should == 20 }
      it { @decorator.num.should == 1 }
    end
  end

end


 

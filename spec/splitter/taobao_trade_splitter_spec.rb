require "spec_helper"

describe "Split a TaobaoTrade's orders" do
  before do
    @trade = create(:taobao_trade)
    @trade.total_fee = 20.0
    @trade.payment = 40.0
    @trade.post_fee = 20.0
    TradeSetting.trade_split_postfee_special_seller_ids = []
  end

  context "while it has no orders" do
    subject { TaobaoTradeSplitter.split_orders(@trade) }

    it { should be_a_kind_of(Array) }
    it { should be_empty }
  end

  context "while it has orders" do
    before do
      @order1 = @trade.orders.build(num: 2, payment: 10.0, total_fee: 10.0, price: 5.0)
      @order2 = @trade.orders.build(num: 1, payment: 10.0, total_fee: 10.0, price: 10.0)
    end

    subject { TaobaoTradeSplitter.split_orders(@trade) }

    it { should be_a_kind_of(Array) }
    it { should_not be_empty }
    it { subject.inject(0.0) { |sum, el| sum + el[:total_fee] }.should == @trade.total_fee }

    describe "post_fee should equal" do
      before do
        TaobaoTradeSplitter.stub(:match_item_sellers).with(Area.first, @order1).and_return([Seller.new(id: 1)])
        TaobaoTradeSplitter.stub(:match_item_sellers).with(Area.first, @order2).and_return([Seller.new(id: 2)])
      end

      context "when has special seller" do
        before do
          TradeSetting.trade_split_postfee_special_seller_ids = [1]
        end

        subject { TaobaoTradeSplitter.split_orders(@trade) }

        it { subject.inject(0.0) { |sum, el| sum + el[:post_fee] }.should == @trade.post_fee }
      end

      context "when has no special seller" do
        subject { TaobaoTradeSplitter.split_orders(@trade) }

        it { subject.inject(0.0) { |sum, el| sum + el[:post_fee] }.should == @trade.post_fee }
      end
    end
  end
end

describe "Match seller" do
  before do
    @trade = create(:taobao_trade)
    @order = @trade.orders.build(num: 10)
  end

  context "when trade has no default area" do
    subject { TaobaoTradeSplitter.match_item_sellers(@trade.default_area, @order) }

    it { should be_a_kind_of(Array) }
    it { should be_empty }
  end

  context "when trade has default area" do
    before do
      @trade.stub(:default_area).and_return(Area.new)
    end

    context "and order has no outer_iid" do
      subject { TaobaoTradeSplitter.match_item_sellers(@trade.default_area, @order) }

      it { should be_a_kind_of(Array) }
      it { should be_empty }
    end

    context "and order has outer_iid" do
      before do
        Product.stub(:find_by_outer_id).and_return(create(:product))
      end

      subject { TaobaoTradeSplitter.match_item_sellers(@trade.default_area, @order) }

      it { should == [] }
    end
  end
end
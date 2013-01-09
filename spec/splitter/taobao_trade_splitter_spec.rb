require "spec_helper"

describe "Split a TaobaoTrade's orders" do
	before do
		@trade = create(:taobao_trade)
	end

  context "while it has no orders" do
		subject { TaobaoTradeSplitter.split_orders(@trade) }

		it { should be_a_kind_of(Array) }
  	it { should be_empty }
  end

  context "while it has orders" do
  	before do
  		@trade.orders.build
		end

		subject { TaobaoTradeSplitter.split_orders(@trade) }

		it { should be_a_kind_of(Array) }
  	it { should_not be_empty }
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
				Product.stub(:find_by_iid).and_return(create(:product))
			end
		  
		  subject { TaobaoTradeSplitter.match_item_sellers(@trade.default_area, @order) }

		  it { should == [] }
		end
	end

end
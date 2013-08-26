# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock_out_bill do
    tid Faker::Lorem.characters(20)
    stock_type "ORS"
    bill_products {|obj| [FactoryGirl.build(:bill_product,:sku_id => FactoryGirl.create(:sku,:account_id => obj.account_id).id)] }

    [:created, :checked, :syncking, :syncked,
      :synck_failed, :stocked, :closed, :canceling,
      :canceld_ok, :canceld_failed].each do |s_name|
      trait s_name do
        status s_name.to_s.upcase
      end
    end

    [:none, :activated, :locked].each_with_index do |opt, idx|
      trait opt do
        operation opt.to_s
        if idx > 0
          operation_time Time.now
        end
      end
    end

    [:none, :activated, :locked].each do |opt|
      [:created, :checked, :syncking, :syncked,
      :synck_failed, :stocked, :closed, :canceling,
      :canceld_ok, :canceld_failed].each do |s_name|
        factory "#{opt}_#{s_name}_stock_out_bill", traits: [opt, s_name]
      end
    end
  end
end

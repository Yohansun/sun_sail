namespace :magic_order do
  task :setup_default_sellers_for_gnc => :environment do
    Account.find(10).settings.default_seller_id = 5725
    Account.find(10).settings.default_jingdong_seller_id = 5725
    Account.find(10).settings.default_yihaodian_seller_id = 5725
  end
end
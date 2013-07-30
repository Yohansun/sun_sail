# -*- encoding : utf-8 -*-

desc "添加京东测试TradeSource和Account"
task :add_jingdong_source => :environment do
  account = Account.create(name: "京东测试店铺", key: "jingdong_test")
  trade_source = TradeSource.create(account_id: account.id,
                                    name: account.name,
                                    app_key: "464FAF98259A48A0E69D341BFC4A387A",
                                    secret_key: "890a2bba25204c84a67fad9db17edea5",
                                    title: account.name)
  JingdongAppToken.create(account_id: account.id,
                          access_token: "84d516a4-19c7-47b3-9d75-a9f6e78bbe91",
                          refresh_token: "771ad62f-7972-4534-98e1-feba876cc63d",
                          trade_source_id: trade_source.id)
  p "Succeed!"
end
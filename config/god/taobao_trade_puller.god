###### TRADE SOURCE

### KEEP AWAY
# 100 babybetter母婴旗舰店
# 204 万科白马欧美母婴店
# 205 欧贝贝organic baby有机棉婴儿用品店
# 208 榜眼图书专营店
# 209 优悠汇
# 210 粉兔珍宝
# 212 爱肯官方旗舰店
# 213 叶卫洋
# 214 优衣库官方旗舰店


### READY TO USE
# 201 白兰氏官方旗舰店
# 206 瑞莱旗舰店
# 207 gnc雍恒专卖店
# 211 大自然官方旗舰店
# 215 伊佳仁家纺旗舰店
# 219 theme旗舰店
# 223 cslr旗舰
# 222 测试店铺


# God::Contacts::Email.defaults do |d|
#   d.from_email = 'errors@networking.io'
#   d.from_name = 'Magic-Solo God Warnings'
#   d.delivery_method = :sendmail
# end
# 
# God.contact(:email) do |c|
#   c.name = 'god'
#   c.group = 'errors'
#   c.to_email = 'errors@networking.io'
# end
# 
# taobao_trade_source_ids = [201,206,207,211,215,219,222,223]
# God.watch do |w|
#   w.name = "taobao_puller"
#   w.group = 'magic_solo'
#   app_root = "/home/rails/server/magic-solo/current"
#   w.log = "#{app_root}/log/taobao_puller_god.log"
# 
#   cmd_string = ""
#   taobao_trade_source_ids.each do |taobao_trade_source_id|
#     cmd_string += "TaobaoTradePuller.create(nil, nil, #{taobao_trade_source_id});TaobaoTradePuller.update(nil, nil, #{taobao_trade_source_id});"
#   end
#   w.interval = 600.seconds
# 
#   w.start = "cd #{app_root}; #{app_root}/script/rails runner -e production '#{cmd_string}'"
# 
#   w.start_if do |start|
#     start.condition(:process_running) do |c|
#       c.interval = 10.minutes
#       c.running = false
#       c.notify = {:contacts => ['errors'], :priority => 1, :category => 'TAOBAOTRADEPULLER'}
#     end
#   end
# end
###### TRADE SOURCE

### KEEP AWAY
# 100 babybetter母婴旗舰店
# 204 万科白马欧美母婴店
# 205 欧贝贝organic baby有机棉婴儿用品店

### READY TO USE
# 201 白兰氏官方旗舰店
# 206 瑞莱旗舰店
# 207 gnc雍恒专卖店
# 208 榜眼图书专营店
# 209 优悠汇
# 210 粉兔珍宝

God::Contacts::Email.defaults do |d|
  d.from_email = 'errors@networking.io'
  d.from_name = 'Magic-Solo God Warnings'
  d.delivery_method = :sendmail
end

God.contact(:email) do |c|
  c.name = 'god'
  c.group = 'errors'
  c.to_email = 'errors@networking.io'
end

taobao_trade_source_ids = [201,206,207,208,209,210]
God.watch do |w|
  w.name = "taobao_puller"
  w.group = 'magic_solo'
  app_root = "/home/rails/server/magic-solo/current"
  w.log = "#{app_root}/log/taobao_puller_god.log"

  cmd_string = ""
  taobao_trade_source_ids.each do |taobao_trade_source_id|
    cmd_string += "TaobaoTradePuller.create(nil, nil, #{taobao_trade_source_id});TaobaoTradePuller.update(nil, nil, #{taobao_trade_source_id});"
  end

  w.start = "cd #{app_root}; #{app_root}/script/rails runner -e production '#{cmd_string}'"

  w.interval = 600.seconds

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
      c.notify = {:contacts => ['errors'], :priority => 1, :category => 'TAOBAOTRADEPULLER'}
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.notify = {:contacts => ['errors'], :priority => 1, :category => 'TAOBAOTRADEPULLER'}
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.notify = {:contacts => ['errors'], :priority => 1, :category => 'TAOBAOTRADEPULLER'}
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.notify = {:contacts => ['errors'], :priority => 1, :category => 'TAOBAOTRADEPULLER'}
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
      c.notify = {:contacts => ['errors'], :priority => 1, :category => 'MAIN'}
    end
  end
end

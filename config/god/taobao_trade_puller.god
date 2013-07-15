[201,204].each do |taobao_trade_source_id|
  God.watch do |w|
    w.name = "taobao_puller_#{taobao_trade_source_id}"
    w.group = 'magic_solo'
    app_root = "/home/rails/server/magic-solo/current"
    w.log = "#{app_root}/log/taobao_puller_god_#{taobao_trade_source_id}.log"

    w.start = "cd #{app_root}; #{app_root}/script/rails runner -e production 'TaobaoTradePuller.create(nil, nil, #{taobao_trade_source_id});TaobaoTradePuller.update(nil, nil, #{taobao_trade_source_id})'"
    w.interval = 300.seconds

    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.running = false
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_exits)
    end
  end
end

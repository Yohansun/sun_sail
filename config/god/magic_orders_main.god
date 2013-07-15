rails_env   = ENV['RAILS_ENV']  || "production"
rails_root  = ENV['RAILS_ROOT'] || "/home/rails/server/magic-solo/current"
num_workers = rails_env == 'production' ? 1 : 1

num_workers.times do |num|
  God.watch do |w|
    w.dir      = "#{rails_root}"
    w.name     = "magic_solo_main#{num}"
    w.group    = 'magic_solo'
    w.interval = 30.seconds

    # 可选队列 sms email jingdong taobao_purchase taobao
    w.start = "bundle exec sidekiq -q trade_manual_notify -q reporter -q delay_auto_dispatch -q taobao_memo_fetcher -q taobao_promotion_fetcher -q taobao -q biaogan -q taobao_memo_sync -q unusual_state_marker -q customer_fetch -q one_hit_fetcher -q trade_taobao_auto_deliver -q customer_message -e production"

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
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
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end

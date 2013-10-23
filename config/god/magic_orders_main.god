rails_env   = ENV['RAILS_ENV']  || "production"
rails_root  = ENV['RAILS_ROOT'] || "/home/rails/server/magic-solo/current"
num_workers = rails_env == 'production' ? 1 : 1

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

num_workers.times do |num|
  God.watch do |w|
    w.dir      = "#{rails_root}"
    w.name     = "magic_solo_main#{num}"
    w.group    = 'magic_solo'
    w.interval = 30.seconds

    # 可选队列 sms email jingdong taobao_purchase taobao
    w.start = "bundle exec sidekiq -q trade_deliver -q trade_yihaodian_deliver -q trade_jingdong_deliver -q yihaodian_refund_order_marker -q jingdong_refund_order_marker -q biaogan -q puller -q trade_manual_notify -q auto_process -q taobao_memo_fetcher -q taobao_promotion_fetcher -q one_hit_fetcher -q customer_message -q init_user_notifier -q reporter -q customer_fetch -e production &> log/sidekiq.log"

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
        c.notify = {:contacts => ['errors'], :priority => 1, :category => 'MAIN'}
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
        c.notify = {:contacts => ['errors'], :priority => 1, :category => 'MAIN'}
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
        c.notify = {:contacts => ['errors'], :priority => 1, :category => 'MAIN'}
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
end

###### ACCOUNT ID

### READY TO USE
# 10 gnc雍恒专卖店


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

jingdong_account_ids = [10]
God.watch do |w|
  w.name = "jingdong_puller"
  w.group = 'magic_solo'
  app_root = "/home/rails/server/magic-solo/current"
  w.log = "#{app_root}/log/jingdong_puller_god.log"

  cmd_string = ""
  jingdong_account_ids.each do |jingdong_account_id|
    cmd_string += "JingdongTradePuller.create(nil, nil, #{jingdong_account_id})"
  end

  w.start = "cd #{app_root}; #{app_root}/script/rails runner -e production '#{cmd_string}'"

  w.interval = 600.seconds

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
      c.notify = {:contacts => ['errors'], :priority => 1, :category => 'JINGDONGTRADEPULLER'}
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.notify = {:contacts => ['errors'], :priority => 1, :category => 'JINGDONGTRADEPULLER'}
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.notify = {:contacts => ['errors'], :priority => 1, :category => 'JINGDONGTRADEPULLER'}
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.notify = {:contacts => ['errors'], :priority => 1, :category => 'JINGDONGTRADEPULLER'}
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
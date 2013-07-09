namespace :sidekiq do
  desc "Stop sidekiq"
  task :stop do
    system "bundle exec sidekiqctl stop #{pidfile}"
  end

  desc "Start sidekiq"
  task :start do
    system "nohup bundle exec sidekiq -C #{file_path('config','sidekiq.yml')}  -e #{Rails.env} -P #{pidfile} >> #{file_path("log", "sidekiq.log")} 2>&1 &"
  end

  desc "Start sidekiq with launchd on Mac OS X"
  task :launchd do
    system "bundle exec sidekiq -C #{file_path('config','sidekiq.yml')} -e #{Rails.env} -P #{pidfile} >> #{file_path("log","sidekiq.log")} 2>&1"
  end

  def pidfile
    Rails.root.join("tmp", "pids", "sidekiq.pid")
  end
  
  def file_path(*args)
    Rails.root.join(*args)
  end
end

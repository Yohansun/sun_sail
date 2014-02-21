RAILS_ROOT = File.expand_path("../../..",__FILE__)
namespace :sidekiq do
  desc "Stop sidekiq"
  task :stop do
    system "bundle exec sidekiqctl stop #{pidfile}"
  end

  desc "Restart sidekiq"
  task :restart => [:stop,:start] do
  end

  desc "Start sidekiq"
  task :start do
    system "nohup bundle exec sidekiq -C #{file_path('config','sidekiq.yml')}  -e #{ENV["RAILS_ENV"] || 'production'} -P #{pidfile} >> #{file_path("log", "sidekiq.log")} 2>&1 &"
  end

  desc "Start sidekiq with launchd on Mac OS X"
  task :launchd do
    system "bundle exec sidekiq -C #{file_path('config','sidekiq.yml')} -e #{ENV["RAILS_ENV"] || 'production'} -P #{pidfile} >> #{file_path("log","sidekiq.log")} 2>&1"
  end

  def pidfile
    File.join(RAILS_ROOT,"tmp/pids/sidekiq.pid")
  end

  def file_path(*args)
    args.unshift RAILS_ROOT
    File.join(*args)
  end
end

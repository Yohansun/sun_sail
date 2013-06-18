# -*- encoding : utf-8 -*-
set :rvm_ruby_string, '1.9.3'
set :rvm_type, :system

set :repository, "git@git.networking.io:nioteam/magic_orders.git"
set :branch, "magicd0509"

server "magicd.networking.io", :web, :app, :db, primary: true
set :user, "root"
set :deploy_to, "/var/rails/magic_orders"


# tasks
namespace :deploy do

  desc "Restart web server"
  task :restart, roles: :app, except: {no_release: true} do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  desc "Symlink shared resources on each release"
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/mailers.yml #{release_path}/config/mailers.yml"
    run "ln -nfs #{shared_path}/config/magic_setting.yml #{release_path}/config/magic_setting.yml"
    run "ln -nfs #{shared_path}/config/jingdong.yml #{release_path}/config/jingdong.yml"
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
    run "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"
    run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run "ln -nfs #{shared_path}/system #{release_path}/public/system"
    run "ln -nfs #{shared_path}/data #{release_path}/data"

    run "chmod -R 0777 #{release_path}"
  end
end

after 'deploy:finalize_update', 'deploy:symlink_shared'
namespace :db do
  desc "migrate db"
  task :migrate, :roles => :app do
    run "cd #{release_path} && RAILS_ENV=production rake db:migrate"
  end
end

namespace :sidekiq do
  desc "restart sidekiq"
  task :restart, :roles => :app do
    run "rvmsudo god restart magic_orders"
    run "rvmsudo god restart magic_orders_pullers"
  end
end

after 'deploy:create_symlink', 'sidekiq:restart'
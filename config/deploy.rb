# -*- encoding : utf-8 -*-
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.3'        # Or whatever env you want it to run in.
set :rvm_type, :user

set :user, "nio"
set :repository, "git@github.com:nioteam/magic_orders.git"
set :branch, "master"
set :deploy_to, "/data/www/magic_orders"
require 'bundler/capistrano'

role :web, "magicalpha.doorder.com" # Your HTTP server, Apache/etc
role :app, "magicalpha.doorder.com" # This may be the same as your `Web` server
role :db, "magicalpha.doorder.com", :primary => true # This is where Rails migrations will run

set :use_sudo, false
set :scm, :git
set :deploy_via, :remote_cache
set :deploy_env, 'production'
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

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
    run "ln -nfs #{shared_path}/config/taobao.yml #{release_path}/config/taobao.yml"
    run "ln -nfs #{shared_path}/config/jingdong.yml #{release_path}/config/jingdong.yml"
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
    run "ln -nfs #{shared_path}/system #{release_path}/public/system"
  end
end

after 'deploy:finalize_update', 'deploy:symlink_shared'

# -*- encoding : utf-8 -*-
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.2'        # Or whatever env you want it to run in.

require 'bundler/capistrano'

set :rvm_path, "/usr/local/rvm"
set :rvm_bin_path, "/usr/local/rvm/bin"
set :rvm_trust_rvmrcs_flag, 1
set :normalize_asset_timestamps, false

set :application, "magic_orders"

set :use_sudo, false
set :scm, :git
set :deploy_via, :remote_cache

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :keep_releases, 3

set :git_shallow_clone, 1
set :git_enable_submodules, 1

role :web, "magicbeta.doorder.com" # Your HTTP server, Apache/etc
role :app, "magicbeta.doorder.com" # This may be the same as your `Web` server
role :db, "magicbeta.doorder.com", :primary => true # This is where Rails migrations will run

set :user, "root"
set :repository, "git@github.com:nioteam/magic_orders.git"
set :branch, "master"
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
    run "ln -nfs #{shared_path}/config/taobao.yml #{release_path}/config/taobao.yml"
    run "ln -nfs #{shared_path}/config/jingdong.yml #{release_path}/config/jingdong.yml"
    run "ln -nfs #{shared_path}/system #{release_path}/public/system"
  end
end

after 'deploy:finalize_update', 'deploy:symlink_shared'

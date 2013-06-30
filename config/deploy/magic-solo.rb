# -*- encoding : utf-8 -*-
require 'hipchat/capistrano'

set :rvm_ruby_string, '1.9.3'
set :rvm_type, :system

set :repository, "git@git.networking.io:nioteam/magic_orders.git"
set :branch, "solo_dev"

server "magic-solo.networking.io", :web, :app, :db, primary: true
set :user, "root"
set :deploy_to, "/var/rails/magic-solo"

set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)

set :hipchat_token, "4cbf6fde19410295cad3d202a87ade"
set :hipchat_room_name, "Release House"
set :hipchat_announce, false
# tasks
namespace :deploy do

   namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} #{assets_dependencies.join ' '} | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end

  desc "Restart web server"
  task :restart, roles: :app, except: {no_release: true} do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end


  desc "restart all monit tasks"
  task :monit_restart_all do
    run "monit restart all"
  end

  desc "Symlink shared resources on each release"
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/sidekiq.yml #{release_path}/config/sidekiq.yml"
    run "ln -nfs #{shared_path}/config/mailers.yml #{release_path}/config/mailers.yml"
    run "ln -nfs #{shared_path}/config/magic_setting.yml #{release_path}/config/magic_setting.yml"
    run "ln -nfs #{shared_path}/config/jingdong.yml #{release_path}/config/jingdong.yml"
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
    run "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"
    run "ln -nfs #{shared_path}/system #{release_path}/public/system"
    run "ln -nfs #{shared_path}/data #{release_path}/data"

    run "chmod -R 0777 #{release_path}"
  end
end

after 'deploy:finalize_update', 'deploy:symlink_shared'
before "deploy:restart", "deploy:monit_restart_all"

namespace :db do
  desc "migrate db"
  task :migrate, :roles => :app do
    run "cd #{release_path} && RAILS_ENV=production rake db:migrate"
  end
end


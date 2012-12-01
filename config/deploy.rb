# -*- encoding : utf-8 -*-
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
require "capistrano/ext/multistage"       #多stage部署所需
require 'bundler/capistrano'       #添加之后部署时会调用bundle install
require 'tinder'

set :stages, %w(magicalpha magictest magicd magicnippon)
set :default_stage, "magictest"

set :application, "magic_orders"

set :use_sudo, false
set :scm, :git
set :git_shallow_clone, 1
set :git_enable_submodules, 1
# set :deploy_via, :remote_cache
set :deploy_env, 'production'
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :deployer, `whoami`.chomp

def campfire_say(words)
    campfire = Tinder::Campfire.new 'nio8', token:'398fa673d19f947080feec19139fa877551a7ea2', ssl_options: {verify:false}
    room = campfire.find_room_by_id('527885')
    room.speak words
end

namespace :notify do
  desc 'Alert Campfire of a deploy'
  task :campfire_start do
    campfire_say "[CAP] #{deployer} is deploying #{application} to #{stage}..."
  end

  task :campfire_end do
    campfire_say "[CAP] #{deployer} has deployed #{application} to #{stage}, it's cool!"
  end
end

before "deploy:update", "notify:campfire_start"
after "deploy:restart", "notify:campfire_end"

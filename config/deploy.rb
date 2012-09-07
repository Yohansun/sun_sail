# -*- encoding : utf-8 -*-
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
require "capistrano/ext/multistage"       #多stage部署所需  
require 'bundler/capistrano'       #添加之后部署时会调用bundle install

set :stages, %w(production magica1) 
set :default_stage, "production" 

set :application, "magic_orders"

set :use_sudo, false
set :scm, :git
set :git_shallow_clone, 1
set :git_enable_submodules, 1 
set :deploy_via, :remote_cache
set :deploy_env, 'production'
default_run_options[:pty] = true
ssh_options[:forward_agent] = true




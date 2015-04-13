# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'zuuzlo'
set :deploy_user, 'deploy'
set :scm, :git
set :repo_url, 'git@github.com:zuuzlo/zuuzlo.git'

set :rbenv_type, :system
set :rbenv_ruby, '2.0.0-p598'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

# how many old releases do we want to keep, not much
set :keep_releases, 5
# files we want symlinking to specific entries in shared
set :linked_files, %w{config/database.yml config/secrets.yml}
# dirs we want symlinking to shared
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
# this:
# http://www.capistranorb.com/documentation/getting-started/flow/
# is worth reading for a quick overview of what tasks are called
# and when for `cap stage deploy`

namespace :deploy do
end
require "bundler/capistrano"
load 'deploy/assets'

set :application, "178.79.139.120"
set :user, 'mihai'
set :group, 'www-data'
set :rails_env, 'production'
set :location, "gemart"

role :web, '178.79.139.120'
role :app, '178.79.139.120'
role :db,  '178.79.139.120', :primary => true

set :scm, :git
set :repository,  "git@github.com:dragontech/gemart.git"
set :branch,      "master"
set :deploy_to,   "/srv/www/#{location}"
set :deploy_via,  :remote_cache
set :port, 60000

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, :roles => :app do
    run "cd #{current_path} && bundle exec foreman export upstart /etc/init"
  end

  desc "Start the application services"
  task :start, :roles => :app do
    sudo "start #{application}"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    sudo "stop #{application}"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    sudo "restart #{application}"
  end
end

namespace :deploy do
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/Procfile #{release_path}/Procfile"
    run "ln -nfs #{shared_path}/config/.foreman #{release_path}/.foreman"
  end
end

before 'deploy:assets:precompile', 'deploy:symlink_shared'

before 'deploy:start', 'foreman:export'
after 'deploy:start', 'foreman:start'

before 'deploy:restart', 'foreman:export'
after 'deploy:restart', 'foreman:restart'
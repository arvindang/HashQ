default_run_options[:pty] = true

require "bundler/capistrano"

set :application, "hashqit"
set :repository,  "git@github.com:jmangoubi/Hashqit.git"

set :scm, :git

set :ssh_options, {
  :forward_agent => true
}

set :use_sudo, true
set :deploy_via, :remote_cache
set :group, :hashqit

task :production do
  role :app, "173.255.205.244"
end

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

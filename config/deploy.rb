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

set :bundle_cmd, "rvm 1.9.2 exec bundle"

set :default_environment, {
  :PATH => '/usr/local/bin:/usr/local/rvm/bin:/usr/bin:/bin'
}

task :production do
  role :app, "173.255.205.244"
end

before "deploy:update_code" do
  sudo "sh -c 'if [ -d #{shared_path}/cached-copy ]; then chown -R root:root #{shared_path}/cached-copy; fi'"
  sudo "sh -c 'if [ -d #{shared_path}/cached-copy ]; then chmod -R ga+rw #{shared_path}/cached-copy; fi'"
end

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

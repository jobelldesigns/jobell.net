set :application, "Jo Bell"
default_run_options[:pty] = true
set :deploy_to, "/var/www/vhosts/jobell.net"

set :repository,        '_site'
set :scm,               :none
set :deploy_via,        :copy
set :copy_compression,  :gzip

# use our keys
ssh_options[:forward_agent] = true
set :use_sudo, false

# Clean up old releases
set :keep_releases, 5
after "deploy:update", "deploy:cleanup"

# Define server
role :web, "deploy@mattheath.com"

before 'deploy:update', 'deploy:update_jekyll'

namespace :deploy do

  [:start, :stop, :restart, :finalize_update].each do |t|
    desc "#{t} task is a no-op with jekyll"
    task t, :roles => :app do ; end
  end

  desc 'Run jekyll to update site before uploading'
  task :update_jekyll do
    %x(rm -rf _site/* && jekyll build)
  end

  desc "Setup folder structure"
  task :setup, :except => { :no_release => true } do
    # Create folder structure for cap
    dirs = [deploy_to, releases_path, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d.split('/').last) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')}"
    run "#{try_sudo} chmod g+w #{dirs.join(' ')}" if fetch(:group_writable, true)
  end
end


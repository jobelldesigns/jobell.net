set :application, "Jo Bell"
set :repository,  "git@github.com:mattheath/jobell.net.git"
set :scm, :git
default_run_options[:pty] = true
set :deploy_to, "/var/www/vhosts/jobell.net"

# use our keys, make sure we grab submodules, try to keep a remote cache
ssh_options[:forward_agent] = true
set :git_enable_submodules, 1
set :deploy_via, :remote_cache
set :use_sudo, false

# Clean up old releases
set :keep_releases, 5
after "deploy:update", "deploy:cleanup"

# Define server
role :web, "deploy@mattheath.com"

namespace :deploy do
  desc "Restart web server (reload apache)"
  task :restart do
    # Reload apache config
    run "sudo /etc/init.d/httpd reload"
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


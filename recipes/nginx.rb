include_recipe 'nginx'
include_recipe 'monit'

rails_apps.each do |app|
  nginx = app.nginx
  cache_root = node[:rails_stack][:nginx][:cache_root]
  cache_store_dir = ::File.join(cache_root, app.full_name)

  directory cache_store_dir do
    recursive true
    user node[:nginx][:user]
    group node[:nginx][:group]
    action :create
  end

  template "nginx_#{app.full_name}" do
    variables({ app: app })
    source 'nginx_conf.erb'
    path nginx.available_file
    mode 00660
    owner node[:nginx][:user]
    group node[:nginx][:group]
    backup 5
    action :create
  end

  # Rotate error and access logs
  logrotate_app "nginx-#{app.full_name}" do
    cookbook "logrotate"
    path [
      nginx.access_log_path,
      nginx.error_log_path
    ]
    options %w(compress missingok delaycompress notifempty)
    frequency "daily"
    size 10 * 1024**2 # 10 MB
    rotate 31
    create "640 #{app[:user]} #{app[:group]}"
    postrotate %~[ -f #{node[:nginx][:pid]} ] && kill -USR1 `cat #{node[:nginx][:pid]}`~
  end

  link nginx.enabled_file do
    to nginx.available_file
  end
end

service "nginx" do
  action :reload
end

monit_monitrc "nginx" do
  notifies :restart, "service[monit]"
end

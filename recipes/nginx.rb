include_recipe 'nginx'
include_recipe 'monit'

rails_apps.each do |app|
  nginx = app.nginx

  directory nginx.cache_path do
    recursive true
    user node[:nginx][:user]
    group node[:nginx][:group]
    action :create
  end

  template "nginx_#{app.full_name}" do
    variables({ app: app })
    source app.nginx[:template_file]
    path nginx.available_file
    mode 00660
    owner node[:nginx][:user]
    group node[:nginx][:group]
    backup 5
    action :create
  end

  template "nginx_global_conf" do
    source 'nginx/global.conf.erb'
    path '/etc/nginx/conf.d/global.conf'
    mode 00660
    owner node[:nginx][:user]
    group node[:nginx][:group]
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

if enable_logentries?
  nginx_logs = {
    'nginx:access' => '/var/log/nginx/access.log',
    'nginx:error' => '/var/log/nginx/error.log'
  }

  rails_apps.each do |app|
    if app.enable_logentries?
      nginx_logs[app.short_name + ':nginx:access'] = app.nginx.access_log_path
      nginx_logs[app.short_name + ':nginx:error'] = app.nginx.error_log_path
    end
  end

  nginx_logs.each do |name, path|
    logentries path do
      log_name name
      action :follow
    end
  end
end

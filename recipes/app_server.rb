include_recipe 'rails_stack::sudoers'

rails_apps.each do |app|
  app_server = app.app_server

  # create unicorn configuration file
  template app.app_server.config_file do
    variables :app => app, :app_server => app_server
    source "#{app_server.name}.rb.erb"
    mode 00660
    owner app_server[:user]
    group app_server[:group]
  end

  directory app.log_dir do
    owner app_server[:user]
    group "root"
    mode 00770
    action :create
  end

  # rotate the unicorn stderr and stdout log files
  logrotate_app "#{app.full_name}-#{app_server.name}" do
    cookbook "logrotate"
    path [ app_server.stdout_log, app_server.stderr_log ].compact
    options %w(compress missingok delaycompress notifempty)
    frequency "daily"
    size 10024**2 # 10 MB
    rotate 31
    create "640 #{app_server[:user]} #{app_server[:group]}"
    postrotate %~kill -USR1 `cat #{app_server.pid_file}`~
  end

  if app.enable_logentries?
    logentries app_server.stdout_log do
      log_name app.short_name + ':unicorn:stdout'
      action :follow
    end

    logentries app_server.stderr_log do
      log_name app.short_name + ':unicorn:stderr'
      action :follow
    end
  end

  # create unicorn init file
  template app_server.init_file do
    variables :app => app, :app_server => app_server
    source "#{app_server.name}.init.erb"
    mode 00770
    owner "root"
    group "root"
  end

  # register unicorn_rails as a service
  service app_server.service_name do
    provider Chef::Provider::Service::Init::Debian
    supports :start => true, :stop => true, :restart => true
    action :enable
  end
end

# create unicorn monit
monit_monitrc 'rails_app_servers' do
  variables :apps => rails_apps
  notifies :restart, "service[monit]"
end

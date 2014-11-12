is_resque_enabled = false
is_resque_web_enabled = false
is_resque_scheduler_enabled = false

rails_apps.each do |app|
  next unless app.resque.pool?
  logentries_logs = {}

  # create the resque-pool config file
  template app.resque.config_file do
    variables :app => app
    source "resque-pool.yml.erb"
    mode 00660
    owner app.resque[:user]
    group app.resque[:group]
  end

  template app.resque.init_file do
    variables :app => app
    source "resque-pool.init.erb"
    mode 00770
    owner "root"
    group "root"
  end

  # register as a service
  service app.resque.service_name do
    provider Chef::Provider::Service::Init::Debian
    supports :start => true, :stop => true, :restart => true
    action :enable
  end

  # rotate the resque logs
  logrotate_app app.resque.service_name do
    cookbook "logrotate"
    path [ app.resque.stdout_log, app.resque.stderr_log, app.resque.init_log ]
    options %w(compress missingok delaycompress notifempty copytruncate)
    frequency "daily"
    rotate 14
    postrotate %~kill -HUP `cat #{app.resque.pid_file}`~
  end

  logentries_logs.merge!(
    'resque:stdout' => app.resque.stdout_log,
    'resque:stderr' => app.resque.stderr_log,
    'resque:init' => app.resque.init_log,
  )

  if app.resque_scheduler.enabled?
    # create the init script for resque-scheduler
    template app.resque_scheduler.init_file do
      source "resque-scheduler.init.erb"
      mode 00770
      owner "root"
      group "root"
      variables({ app: app })
    end

    # register resque-scheduler as a service
    service app.resque_scheduler.service_name do
      provider Chef::Provider::Service::Init::Debian
      supports :start => true, :stop => true, :restart => true
      action :enable
    end

    # rotate the resque-scheduler logs
    logrotate_app app.resque_scheduler.service_name do
      cookbook "logrotate"
      path app.resque_scheduler.log_files_glob
      options %w(compress missingok delaycompress notifempty copytruncate)
      frequency "daily"
      rotate 14
    end

    logentries_logs.merge!(
      'resque-sch:stdout' => app.resque_scheduler.stdout_log,
      'resque-sch:stderr' => app.resque_scheduler.stderr_log,
      'resque-sch:init' => app.resque_scheduler.init_log
    )

    is_resque_scheduler_enabled = true
  end

  if app.resque_web

    # create the init script for resque-web
    template app.resque_web.init_file do
      source "resque-web.init.erb"
      mode 00770
      owner "root"
      group "root"
      variables({ app: app })
    end

    # register resque-web as a service
    service app.resque_web.service_name do
      provider Chef::Provider::Service::Init::Debian
      supports :start => true, :stop => true, :restart => true
      action :enable
    end

    # rotate the resque-web logs
    logrotate_app app.resque_web.service_name do
      cookbook "logrotate"
      path app.resque_web.log_files_glob
      options %w(compress missingok delaycompress notifempty copytruncate)
      frequency "daily"
      rotate 14
    end

    is_resque_web_enabled = true
  end

  is_resque_enabled = true

  logentries_logs.each do |name, path|
    logentries path do
      log_name app.short_name + ':' + name
      action :follow
    end
  end
end

if is_resque_enabled
  monit_monitrc "resque-pool" do
    notifies :restart, "service[monit]"
    variables :apps => rails_apps
  end
end

if is_resque_web_enabled
  monit_monitrc "resque-web" do
    notifies :restart, "service[monit]"
    variables :apps => rails_apps
  end
end

if is_resque_scheduler_enabled
  monit_monitrc "resque-scheduler" do
    notifies :restart, "service[monit]"
    variables :apps => rails_apps
  end
end

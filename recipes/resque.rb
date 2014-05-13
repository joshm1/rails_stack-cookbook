rails_apps.each do |app|
  next unless app.resque.pool?

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
    options %w(compress missingok delaycompress notifempty)
    frequency "daily"
    rotate 10
    create "640 #{app.resque[:user]} #{app.resque[:group]}"
  end

  if false #app.resque_web
    has_resque_web = true

    # create the init script for resque-web
    template "/etc/init.d/#{app.resque_web[:service]}" do
      source "resque-web.init.erb"
      mode 00770
      owner "root"
      group "root"
      variables({ app: app })
    end

    # register resque-web as a service
    service app.resque_web[:service] do
      provider Chef::Provider::Service::Init::Debian
      supports :start => true, :stop => true, :restart => true
      action :enable
    end

    # rotate the resque-web logs
    logrotate_app app.resque_web[:service] do
      cookbook "logrotate"
      path app.resque_web[:log_file]
      options %w(compress missingok delaycompress notifempty)
      frequency "daily"
      rotate 10
      create "640 #{app.app_user} #{app.app_group}"
    end
  end
end

monit_monitrc "resque-pool" do
  notifies :restart, "service[monit]"
  variables :apps => rails_apps
end

#monit_monitrc "resque-web" do
#  notifies :restart, "service[monit]"
#  variables({ apps: recipe.apps })
#end

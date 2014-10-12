rails_apps.each do |app|

  [
    app.project_root_dir,
    app.releases_dir,
    app.shared_dir,
    app.config_dir,
    app.log_dir,
    app.tmp_dir,
    app.pids_dir,
    app.sockets_dir
  ].each do |dir|
    directory dir do
      owner app[:user]
      group app[:group]
      mode 0751
      recursive true
      action :create
    end
  end

  # rotate the rails log file
  logrotate_app "#{app.full_name}-rails" do
    cookbook "logrotate"
    path app.rails_log
    options %w(compress missingok delaycompress notifempty)
    frequency "daily"
    rotate 60
    create "640 #{app[:user]} #{app[:group]}"
    if app.app_server.run? && app.app_server.name == 'unicorn'
      # unicorn specific signal to rotate log file
      postrotate %~kill -USR1 `cat #{app.app_server.pid_file}`~
    end
  end

  if app.enable_logentries?
    logentries app.rails_log do
      log_name app.short_name + ':rails'
      action :follow
    end

    logentries ::File.join(app.log_dir, 'cron.log') do
      log_name app.short_name + ':' + 'cron'
      action :follow
    end
  end

  if app[:database]
    # assumes postgresql currently
    template ::File.join(app.config_dir, 'database.yml') do
      user app[:user]
      group app[:group]
      source 'database.yml.erb'
      variables({
        environment: app.environment,
        db_name: app[:database][:name],
        username: app[:database][:username],
        password: app[:database][:password],
        host: app[:database][:host],
        adapter: 'postgresql'
      })
    end

    package 'libpq-dev' do
      action :install
    end
  end
end

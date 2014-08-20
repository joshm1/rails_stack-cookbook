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
      mode 0771
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
    create "640 #{app_server[:user]} #{app_server[:group]}"
    postrotate %~kill -USR1 `cat #{app_server.pid_file}`~
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

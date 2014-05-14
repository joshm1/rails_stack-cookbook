rails_apps.each do |app|

  [
    app.project_root_dir,
    app.releases_dir,
    app.shared_dir,
    app.config_dir,
    app.log_dir,
    app.tmp_dir,
    app.pids_dir
  ].each do |dir|
    directory dir do
      owner app[:user]
      group app[:group]
      mode 0771
      recursive true
      action :create
    end
  end

  if app[:database]
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
  end
end

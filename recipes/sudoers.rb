rails_apps.each do |app|
  nopasswds = []
  nopasswds << app.app_server.init_file if app.app_server.run?
  nopasswds << app.resque.init_file if app.resque.pool?

  template "/etc/sudoers.d/#{app.full_name}" do
    variables :app => app, :nopasswd_files => nopasswds.join(', ')
    source "sudoer.erb"
    owner 'root'
    group 'root'
    mode 00440
  end
end

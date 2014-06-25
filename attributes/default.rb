default[:rails_stack][:packages] = %w(git nodejs vim-common)
default[:rails_stack][:install_ruby2] = true
default[:rails_stack][:global][:user] = 'apps'
default[:rails_stack][:global][:user_home] = '/u/apps'
default[:rails_stack][:global][:group] = 'apps'

default[:rails_stack][:global][:nginx] = {
  cache_root: '/mnt/nginx_cache',
  listen: 80,
  server_names: '_',
  log_dir: default[:nginx][:log_dir],
  proxy_read_timeout: 30,
  proxy_connect_timeout: 10,
  ssl: {
    listen: 443
  },
}

default[:rails_stack][:global][:resque] = {
  user: default[:rails_stack][:global][:user],
  group: default[:rails_stack][:global][:group]
}

default[:rails_stack][:global][:resque_web] = {
  user: default[:rails_stack][:global][:resque][:user],
  port: 5678,
  load_file: 'config/initializers/resque.rb'
}

default[:rails_stack][:global][:app_server] = {
  provider: 'unicorn',
  workers: 2,
  timeout: 30,
  backlog: 256,
  user: default[:rails_stack][:global][:user],
  group: default[:rails_stack][:global][:group]
}

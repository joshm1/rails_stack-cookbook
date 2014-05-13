default[:rails_stack][:global][:user] = 'apps'
default[:rails_stack][:global][:user_home] = '/u/apps'
default[:rails_stack][:global][:group] = 'apps'
default[:rails_stack][:nginx][:cache_root] = '/mnt/nginx_cache'

default[:rails_stack][:global][:resque] = {
  user: default[:rails_stack][:global][:user],
  group: default[:rails_stack][:global][:group]
}

default[:rails_stack][:global][:app_server] = {
  provider: 'unicorn',
  workers: 2,
  timeout: 30,
  backlog: 256,
  user: default[:rails_stack][:global][:user],
  group: default[:rails_stack][:global][:group]
}

# Add PPA for Ruby 2.x
apt_repository 'brightbox-ruby-ng' do
  uri          'http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu'
  distribution 'precise'
  components   ['main']
  keyserver    'keyserver.ubuntu.com'
  key          'C3173AA6'
end

# Install required packages
%w{ libxml2-dev libxslt-dev ruby2.1 ruby2.1-dev curl ruby-switch }.each do |pkg|
  package pkg do
    action :install
  end
end

bash 'ruby-switch[2.1]' do
  code "ruby-switch --set ruby2.1"
  action :run
end

gem_package 'bundler' do
  gem_binary '/usr/bin/gem2.1'
end

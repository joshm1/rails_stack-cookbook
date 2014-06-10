install_ruby2 = node[:rails_stack][:install_ruby2]
if install_ruby2
  # Add PPA for Ruby 2.x
  apt_repository 'brightbox-ruby-ng' do
    uri          'http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu'
    distribution 'precise'
    components   ['main']
    keyserver    'keyserver.ubuntu.com'
    key          'C3173AA6'
  end
end

# Install required packages
packages = %w{ libxml2-dev libxslt-dev }
packages += install_ruby2 ? %w{ ruby2.1 ruby2.1-dev curl ruby-switch } : %w{ ruby1.9.1-dev }
packages.each do |pkg|
  package pkg do
    action :install
  end
end

if install_ruby2
  bash 'ruby-switch[2.1]' do
    code "ruby-switch --set ruby2.1"
    action :run
  end
end

gem_package 'bundler' do
  gem_binary(install_ruby2 ? '/usr/bin/gem2.1' : '/usr/bin/gem')
end

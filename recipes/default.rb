#
# Cookbook Name:: rails_stack
# Recipe:: default
#
# Copyright 2014, Josh McDade
#
# All rights reserved - Do Not Redistribute
#

node[:rails_stack][:packages].each do |pkg|
  package pkg do
    action :install
  end
end

# Upgrade openssl to latest version
package 'openssl' do
  action :upgrade
end

if enable_logentries?
  # we need this recipe to run before any logs are added
  include_recipe 'logentries'
end

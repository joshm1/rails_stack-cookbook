#
# Cookbook Name:: rails_stack
# Recipe:: default
#
# Copyright 2014, Josh McDade
#
# All rights reserved - Do Not Redistribute
#

package 'git' do
  action :install
end

# Upgrade openssl to latest version
package 'openssl' do
  action :upgrade
end

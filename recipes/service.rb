#
# Cookbook Name:: hekad
# Recipe:: service
#
# Copyright 2015 Nathan Williams
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

group 'heka' do
  system true
  action :create
end

user 'heka' do
  shell '/bin/false'
  system true
  gid 'heka'
end

directory '/var/cache/hekad' do
  owner 'heka'
  group 'heka'
  recursive true
end

# systemd
systemd_service 'hekad' do
  description 'general purpose data acquisition and processing engine'
  documentation 'man:hekad(1) https://hekad.readthedocs.org/'
  install do
    wanted_by 'multi-user.target'
  end
  service do
    user 'heka'
    group 'heka'
    exec_start "/usr/bin/hekad -config=#{node['heka']['config_dir']}"
    restart 'on-failure'
  end
  only_if { Heka::Init.systemd? }
  notifies :restart, 'service[hekad]', :delayed
end

# upstart
template '/etc/init/hekad.conf' do
  source 'hekad.conf'
  variables conf_dir: node['heka']['config_dir']
  only_if { Heka::Init.upstart? }
  notifies :restart, 'service[hekad]', :delayed
end

# sysv
template '/etc/init.d/hekad' do
  source 'hekad.sysv'
  mode '0755'
  variables conf_dir: node['heka']['config_dir']
  not_if { Heka::Init.systemd? || Heka::Init.upstart? }
  notifies :restart, 'service[hekad]', :delayed
end

file '/etc/init.d/heka' do
  action :delete
end

service 'heka' do
  action [:stop, :disable]
  subscribes :stop, 'package[heka]', :immediately
end

service 'hekad' do
  provider Chef::Provider::Service::Upstart if Heka::Init.upstart?
  action [:start, :enable]
  subscribes :restart, 'package[heka]', :delayed
  subscribes :restart, 'heka_config[hekad]', :delayed
end

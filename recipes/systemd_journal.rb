#
# Cookbook Name:: hekad
# Recipe:: systemd
#
# Copyright 2015 Nathan Williams <nath.e.will@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Also requires 'ForwardToSyslog=yes' in journald.conf
heka_config 'journal_syslog_input' do
  config(
    'journal_syslog_input' => {
      'type' => 'UdpInput',
      'address' => '/run/systemd/journal/syslog',
      'net' => 'unixgram',
      'decoder' => 'journal_syslog_decoder'
    }
  )
  notifies :restart, 'service[hekad]', :delayed
end

heka_config 'journal_syslog_decoder' do
  config(
    'journal_syslog_decoder' => {
      'type' => 'SandboxDecoder',
      'filename' => 'lua_decoders/rsyslog.lua',
      'config' => {
        'type' => 'journal_syslog',
        'template' => '<%syslogfacility%>%timestamp% %syslogtag%%msg%',
        'hostname_keep' => true
      }
    }
  )
  notifies :restart, 'service[hekad]', :delayed
end

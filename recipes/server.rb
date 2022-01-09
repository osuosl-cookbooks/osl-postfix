#
# Cookbook:: osl-postfix
# Recipe:: server
#
# Copyright:: 2018-2022, Oregon State University
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

include_recipe 'osl-selinux' if platform_family?('rhel')

node['osl-postfix']['main'].each do |key, value|
  node.default['postfix']['main'][key] = value
end

node['osl-postfix']['aliases'].each do |key, value|
  node.default['postfix']['aliases'][key] = value
end

package 'postfix-perl-scripts' if platform_family?('rhel')

%w(pfcat pfdel).each do |f|
  cookbook_file "/usr/local/sbin/#{f}" do
    source "server/#{f}"
    mode '755'
  end
end

osl_firewall_port 'smtp'

include_recipe 'postfix::server'

#
# Cookbook:: osl-postfix
# Recipe:: default
#
# Copyright:: 2018, Oregon State University
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

node.default['postfix']['mail_type'] = 'client'
node.default['postfix']['main']['myorigin'] = '$mydomain'
node.default['postfix']['main']['smtpd_use_tls'] = 'no'

case node['network']['default_gateway']
# We must use the submission port on these networks
when '10.162.136.1', '128.193.126.193', '148.100.110.1'
  node.default['postfix']['main']['relayhost'] = '[smtp.osuosl.org]:587'
  node.default['postfix']['main']['smtp_use_tls'] = 'yes'
else
  node.default['postfix']['main']['relayhost'] = '[smtp.osuosl.org]:25'
  node.default['postfix']['main']['smtp_use_tls'] = 'no'
end

include_recipe 'postfix'

osl-postfix Cookbook
====================
This cookbook is a wrapper around [postfix](https://github.com/chef-cookbooks/postfix).

Requirements
------------

#### Platforms
- CentOS 6
- CentOS 7
- CentOS 8
- Debian 9 
- Debian 10

#### Cookbooks
- [`postfix`](https://github.com/chef-cookbooks/postfix) - the upstream cookbook that `osl-postfix` wraps

Attributes
----------
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['osl-postfix']['main']</tt></td>
    <td>Hash</td>
    <td>Set attributes for <tt>['postfix']['main']</tt> here and they'll be set in <tt>osl-postfix::attributes</tt></td>
    <td><tt>{}</tt></td>
  </tr>
</table>

Usage
-----
#### osl-postfix::default
Include `osl-postfix::default` for hosts that only need to be able to send mail (functioning as a
postfix client).

#### osl-postfix::server
Include `osl-postfix::server` for hosts that will send and receive mail (functioning as a postfix
server).

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `username/add_component_x`)
3. Write tests for your change
4. Write your change
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
- Author:: Oregon State University <chef@osuosl.org>

```text
Copyright:: 2018, Oregon State University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

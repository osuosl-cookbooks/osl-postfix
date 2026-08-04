osl-postfix Cookbook
====================
Resource-first wrapper around the [`sous-chefs/postfix`](https://github.com/sous-chefs/postfix)
cookbook with OSL TLS / cipher hardening, the OSL submission-port relayhost
logic, and the standard server helper scripts.

The two resources `osl_postfix` and `osl_postfix_server` are **composable**:
the base role calls `osl_postfix 'default'` on every node; downstream
cookbooks on mail-server nodes additionally call `osl_postfix_server 'default'`
to promote that same node to server config. Each call accumulates state into
`node.run_state`; the underlying `postfix 'default'` resource converges
exactly once at the end of the run with the fully-merged state (via Chef's
`delayed_action :create` + `lazy { ... }` pattern, same as the
`chef_auto_accumulator` cookbook).

Requirements
------------

#### Platforms
- AlmaLinux 8, 9, 10
- Debian 12, 13
- Ubuntu 24.04

#### Cookbooks
- [`postfix`](https://github.com/sous-chefs/postfix) `~> 7.0.0` (the upstream
  resource-first postfix cookbook)
- [`osl-firewall`](https://github.com/osuosl-cookbooks/osl-firewall) — for
  the SMTP port on `osl_postfix_server`.
- [`osl-selinux`](https://github.com/osuosl-cookbooks/osl-selinux) — included
  automatically on RHEL-family platforms.

Resources
---------

### `osl_postfix`

General client / outbound-relay configuration. Includes `osl-selinux` on RHEL,
applies OSL TLS hardening defaults, and picks the relayhost from the node's
default gateway (submission port 587 with TLS for known OSL submission-only
gateways, otherwise port 25 plaintext).

```ruby
osl_postfix 'default'                              # accepts the OSL defaults

osl_postfix 'default' do                           # with overrides
  main_settings(
    'mydomain' => 'example.com',
    'relayhost' => '[smtp.example.com]:587'
  )
end
```

Properties (all pass-through to the upstream `postfix` resource):

| Property | Type | Default |
| --- | --- | --- |
| `mail_type` | String | `'client'` (also accepts `'master'`) |
| `main_settings` | Hash | `{}` — merged on top of OSL hardening defaults + gateway-based relayhost |
| `master_settings` | Hash | `{}` |
| `aliases` | Hash | `{}` — only honored when `use_alias_maps true` |
| `access` / `transports` / `virtual_aliases` / `virtual_aliases_domains` / `relay_restrictions` / `maps` / `sasl` | Hash | `{}` |
| `use_alias_maps` / `use_access_maps` / `use_transport_maps` / `use_virtual_aliases` / `use_virtual_aliases_domains` / `use_relay_restrictions_maps` | Bool | `false` |

### `osl_postfix_server`

Mail-server convenience. Forces `mail_type='master'`, `inet_interfaces='all'`,
and `use_alias_maps=true` on the accumulator; seeds `aliases` with
`osl_postfix_system_aliases` if nothing has been accumulated yet. Also
installs `postfix-perl-scripts` on RHEL, deploys `/usr/local/sbin/{pfcat,pfdel}`,
and opens the SMTP firewall port. Works standalone (no prior `osl_postfix`
call needed) or composed on top of a baseline `osl_postfix 'default'` from
the base role.

```ruby
osl_postfix_server 'default'                        # standard server defaults

osl_postfix_server 'default' do                     # with SSL + smtps
  main_settings(
    'smtpd_tls_cert_file' => '/etc/pki/tls/certs/wildcard.pem',
    'smtpd_tls_key_file'  => '/etc/pki/tls/private/wildcard.key',
    'smtpd_use_tls'       => 'yes',
    'smtpd_tls_security_level' => 'may'
  )
  master_settings('smtps' => { 'active' => true })
end
```

Properties: same set as `osl_postfix` minus `mail_type` (fixed at `'master'`).
`use_alias_maps` is hardcoded `true`. `aliases` defaults to `osl_postfix_system_aliases`
when nothing has been accumulated yet; otherwise the caller's hash is merged on top.

`master_settings` deep-merges with the upstream `postfix_default_master_settings`,
so passing only the changed nested keys works as expected:

```ruby
master_settings('smtps' => { 'active' => true })
# → smtps ends up with active=true plus the upstream-default order/type/command/args
```

Helpers
-------

Exposed in `libraries/helpers.rb`:

- `osl_postfix_hardening_defaults` — Hash of TLS/cipher/`myorigin`/etc.
  defaults applied by the resource.
- `osl_postfix_relayhost_for_gateway` — Hash picked by node default gateway.
- `osl_postfix_system_aliases` — the RHEL-8 system aliases Hash.
- `osl_postfix_tls_protocols` / `osl_postfix_tls_exclude_ciphers` /
  `osl_postfix_tls_high_cipherlist` — the raw OSL TLS constants.
- `osl_postfix_state(name)` — accessor for the in-memory accumulator hash
  under `node.run_state[:osl_postfix][name]`. Useful when a cookbook needs
  to mutate state in a way that doesn't fit the resource property API.
- `osl_postfix_ensure_inner_resource(name)` — declares the underlying
  `postfix 'default'` resource with `delayed_action :create` and `lazy { }`
  properties pointing at the accumulator, if not already declared.

Testing
-------

```bash
cinc exec rspec       # unit (ChefSpec) — accumulator state + resource declarations
kitchen test          # integration (InSpec) — rendered main.cf, master.cf, services, ports
```

ChefSpec can't fire `:delayed` notifications, so the unit suite asserts
on `node.run_state[:osl_postfix]` and resource declarations rather than
rendered file content; the kitchen suites cover the rendered configuration.

Roles
-----

`osl-postfix::default` is a one-liner recipe (`osl_postfix 'default'`)
intended for use in the base role's run-list so every node converges with
sane client postfix settings. Cookbooks that need server config simply add
`osl_postfix_server 'default'` later in the converge — the two layer through
`node.run_state`.

Migration from 2.x
------------------

osl-postfix 3.x is a full rewrite. The old `osl-postfix::server` recipe
and the `node['osl-postfix']['...']` / `node['postfix']['...']` attribute
API are **gone** (only `osl-postfix::default` remains, and it just invokes
the resource). The new API is documented above. Per-downstream migration
guidance for affected consumers is being tracked out-of-tree.

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

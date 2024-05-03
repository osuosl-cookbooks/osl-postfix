osl-postfix CHANGELOG
=====================
This file is used to list changes made in each version of the
osl-postfix cookbook.

2.2.5 (2024-05-03)
------------------
- Remove support for Debian 12

2.2.4 (2024-02-08)
------------------
- Revert "Use hostname for myorigin by default"

2.2.3 (2024-02-03)
------------------
- Use hostname for myorigin by default

2.2.2 (2023-08-08)
------------------
- Add Debian 12

2.2.1 (2023-02-08)
------------------
- Support AlmaLinux 8

2.2.0 (2022-01-14)
------------------
- removed support for debian 10

2.1.2 (2021-09-03)
------------------
- added support for debian 11

2.1.1 (2021-06-09)
------------------
- Don't enable STARTTLS by default for servers

2.1.0 (2021-06-08)
------------------
- Use saner TLS/SSL settings

2.0.0 (2021-05-25)
------------------
- Update to new osl-firewall resources

1.6.0 (2021-04-07)
------------------
- Update Chef dependency to >= 16

1.5.2 (2021-03-27)
------------------
- Fix outbound email for hosts on bak.milne.osuosl.org

1.5.1 (2021-03-16)
------------------
- Include default system mail aliases

1.5.0 (2021-01-27)
------------------
- Enable selinux enforcing

1.4.0 (2021-01-13)
------------------
- Remove Centos 6

1.3.0 (2020-11-05)
------------------
- Add pfcat, pfdel scripts from cfengine

1.2.3 (2020-10-30)
------------------
- Set Postfix compatibility level

1.2.2 (2020-10-20)
------------------
- Bump postfix cookbook to 5.4.0

1.2.1 (2020-08-21)
------------------
- Chef 16 Update

1.2.0 (2020-07-01)
------------------
- Remove support for debian 9

1.1.0 (2020-06-01)
------------------
- Chef 15 updates

1.0.3 (2020-01-10)
------------------
- Chef 14 post-migration fixes

1.0.2 (2019-07-09)
------------------
- Add smtp firewall rule for server recipe

1.0.1 (2019-03-06)
------------------
- Add node['osl-postfix']['main'] which sets node['postfix']['main']

1.0.0 (2018-07-30)
------------------
- Add basic postfix client (default) & server recipes

0.1.0
-----
- Initial release of osl-postfix


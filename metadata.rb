name             'osl-postfix'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
source_url       'https://github.com/osuosl-cookbooks/osl-postfix'
issues_url       'https://github.com/osuosl-cookbooks/osl-postfix/issues'
license          'Apache-2.0'
chef_version     '>= 16.0'
description      'Installs/Configures osl-postfix'
version          '1.6.0'

depends          'osl-firewall'
depends          'osl-selinux'
depends          'postfix', '~> 5.4.0'

supports         'centos', '~> 7.0'
supports         'centos', '~> 8.0'
supports         'debian', '~> 10.0'

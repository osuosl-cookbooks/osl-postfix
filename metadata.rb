name             'osl-postfix'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 12.18' if respond_to?(:chef_version)
issues_url       'https://github.com/osuosl-cookbooks/osl-postfix/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-postfix'
description      'Installs/Configures osl-postfix'
long_description 'Installs/Configures osl-postfix'
version          '1.0.2'

depends          'apt'
depends          'firewall'
depends          'postfix', '~> 5.3.0'

supports         'centos', '~> 6.0'
supports         'centos', '~> 7.0'
supports         'debian', '~> 8.0'
supports         'debian', '~> 9.0'


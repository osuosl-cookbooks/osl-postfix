default['osl-postfix']['main'] = {}
default['osl-postfix']['main']['myorigin'] = '$mydomain'
default['osl-postfix']['main']['smtpd_use_tls'] = 'no'

default['osl-postfix']['main']['compatibility_level'] = '2' if platform_version >= 8

case node['network']['default_gateway']
# We must use the submission port on these networks
when '10.162.136.1', '128.193.126.193', '148.100.110.1'
  default['osl-postfix']['main']['relayhost'] = '[smtp.osuosl.org]:587'
  default['osl-postfix']['main']['smtp_use_tls'] = 'yes'
  if platform_family?('debian')
    default['osl-postfix']['main']['smtp_tls_CAfile'] = '/etc/ssl/certs/ca-certificates.crt'
  end
else
  default['osl-postfix']['main']['relayhost'] = '[smtp.osuosl.org]:25'
  default['osl-postfix']['main']['smtp_use_tls'] = 'no'
end

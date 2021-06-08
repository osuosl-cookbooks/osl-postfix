default['osl-postfix']['main'] = {}
default['osl-postfix']['main']['compatibility_level'] = '2' if platform_version >= 8
default['osl-postfix']['main']['lmtp_tls_mandatory_protocols'] = osl_postfix_tls_protocols.join(',')
default['osl-postfix']['main']['lmtp_tls_protocols'] = osl_postfix_tls_protocols.join(',')
default['osl-postfix']['main']['myorigin'] = '$mydomain'
default['osl-postfix']['main']['smtpd_tls_ciphers'] = 'high'
default['osl-postfix']['main']['smtpd_tls_eecdh_grade'] = 'strong'
default['osl-postfix']['main']['smtpd_tls_exclude_ciphers'] = osl_postfix_tls_exclude_ciphers.join(',')
default['osl-postfix']['main']['smtpd_tls_mandatory_protocols'] = osl_postfix_tls_protocols.join(',')
default['osl-postfix']['main']['smtpd_tls_protocols'] = osl_postfix_tls_protocols.join(',')
default['osl-postfix']['main']['smtpd_tls_security_level'] = 'may'
default['osl-postfix']['main']['smtp_tls_ciphers'] = 'high'
default['osl-postfix']['main']['smtp_tls_exclude_ciphers'] = osl_postfix_tls_exclude_ciphers.join(',')
default['osl-postfix']['main']['smtp_tls_mandatory_protocols'] = osl_postfix_tls_protocols.join(',')
default['osl-postfix']['main']['smtp_tls_protocols'] = osl_postfix_tls_protocols.join(',')
default['osl-postfix']['main']['smtp_tls_security_level'] = 'may'
default['osl-postfix']['main']['tls_high_cipherlist'] = osl_postfix_tls_high_cipherlist
default['osl-postfix']['main']['tlsproxy_tls_mandatory_protocols'] = '$smtpd_tls_mandatory_protocols'
default['osl-postfix']['main']['tlsproxy_tls_protocols'] = '$smtpd_tls_protocols'
default['osl-postfix']['aliases'] = osl_postfix_system_aliases

case node['network']['default_gateway']
# We must use the submission port on these networks
when '10.162.136.1', '128.193.126.193', '148.100.110.1', '10.6.4.1'
  default['osl-postfix']['main']['relayhost'] = '[smtp.osuosl.org]:587'
  default['osl-postfix']['main']['smtp_use_tls'] = 'yes'
  if platform_family?('debian')
    default['osl-postfix']['main']['smtp_tls_CAfile'] = '/etc/ssl/certs/ca-certificates.crt'
  end
else
  default['osl-postfix']['main']['relayhost'] = '[smtp.osuosl.org]:25'
  default['osl-postfix']['main']['smtp_use_tls'] = 'no'
end

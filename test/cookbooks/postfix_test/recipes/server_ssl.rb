include_recipe 'certificate::wildcard'

osl_postfix 'default' # simulates the base role baseline

osl_postfix_server 'default' do
  main_settings(
    'smtpd_tls_cert_file' => '/etc/pki/tls/certs/wildcard.pem',
    'smtpd_tls_key_file' => '/etc/pki/tls/private/wildcard.key',
    'smtpd_tls_security_level' => 'may',
    'smtpd_use_tls' => 'yes'
  )
  master_settings(
    'smtps' => { 'active' => true }
  )
end

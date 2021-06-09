control 'postfix-server-ssl' do
  describe port 465 do
    it { should be_listening }
  end

  describe postfix_conf do
    its('smtpd_tls_security_level') { should cmp 'may' }
    its('smtpd_use_tls') { should cmp 'yes' }
  end
end

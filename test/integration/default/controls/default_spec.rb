smtpd_tls_security_level = input('smtpd_tls_security_level')

control 'postfix-default' do
  describe ini '/etc/postfix/main.cf' do
    its('myorigin') { should match '$mydomain' }
    its('relayhost') { should match '[smtp.osuosl.org]:25' }
    its('smtpd_use_tls') { should match 'no' }
    its('smtp_use_tls') { should match 'no' }
    its('smtpd_tls_security_level') { should match smtpd_tls_security_level }
    its('smtp_tls_security_level') { should match 'may' }
    its('compatibility_level') { should match '2' } if os.redhat?
  end

  describe file '/etc/postfix/main.cf' do
    its('content') { should match '# Configured as client' }
  end

  if os[:family] == 'debian'
    describe file '/etc/ssl/certs/ca-certificates.crt' do
      it { should be_file }
    end
  else
    describe file '/etc/ssl/certs/ca-certificates.crt' do
      it { should_not exist }
    end
  end
end

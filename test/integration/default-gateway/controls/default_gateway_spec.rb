control 'postfix-default-gateway' do
  describe postfix_conf do
    its('relayhost') { should cmp '[smtp.osuosl.org]:587' }
    its('smtp_use_tls') { should cmp 'yes' }
  end

  if os[:family] == 'debian'
    describe postfix_conf do
      its('smtp_tls_CAfile') { should cmp '/etc/ssl/certs/ca-certificates.crt' }
    end

    describe file '/etc/ssl/certs/ca-certificates.crt' do
      it { should be_file }
    end
  end

  # Still a client (not a master)
  describe file '/etc/postfix/main.cf' do
    its('content') { should match '# Configured as client' }
  end
end

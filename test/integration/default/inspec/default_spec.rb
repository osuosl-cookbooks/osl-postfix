describe package 'postfix' do
  it { should be_installed }
end

describe service 'postfix' do
  it { should be_running }
end

describe ini '/etc/postfix/main.cf' do
  its('myorigin') { should match '$mydomain' }
  its('relayhost') { should match '[smtp.osuosl.org]:25' }
  its('smtpd_use_tls') { should match 'no' }
  its('smtp_use_tls') { should match 'no' }
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

describe package 'postfix' do
  it { should be_installed }
end

describe service 'postfix' do
  it { should be_running }
end

describe file '/etc/postfix/main.cf' do
  its('content') { should match '# Configured as master' }
end

describe iptables do
  it { should have_rule('-A smtp -p tcp -m tcp --dport 25 -j ACCEPT') }
end

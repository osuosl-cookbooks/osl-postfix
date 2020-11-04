describe file '/etc/postfix/main.cf' do
  its('content') { should match '# Configured as master' }
end

describe iptables do
  it { should have_rule('-A smtp -p tcp -m tcp --dport 25 -j ACCEPT') }
end

describe package 'postfix-perl-scripts' do
  it { should be_installed }
end if os.family == 'redhat'

describe file '/usr/local/sbin/pfcat' do
  it { should exist }
  it { should be_executable }
  its('content') { should match /# pfcat - Helper script to print out mail from the Postfix queues./ }
end

describe command '/usr/local/sbin/pfcat' do
  its('stdout') { should match /Usage: pfcat <queue id>/ }
end

describe command '/usr/local/sbin/pfcat foo' do
  its('exit_status') { should eq 1 }
  its('stdout') { should match /No such queue file foo/ }
end

describe file '/usr/local/sbin/pfdel' do
  it { should exist }
  it { should be_executable }
  its('content') { should match /# pfdel - Deletes message containing specified address from the Postfix queue./ }
end

describe command '/usr/local/sbin/pfdel' do
  its('stderr') { should match /Usage: pfdel <email_address>/ }
end

describe command '/usr/local/sbin/pfdel foo@bar.com' do
  its('exit_status') { should eq 255 }
  its('stderr') { should match /No messages with the address <foo@bar.com> found in queue./ }
end

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

describe file '/etc/aliases' do
  {
    'abuse' => 'root',
    'adm' => 'root',
    'amandabackup' => 'root',
    'apache' => 'root',
    'bin' => 'root',
    'canna' => 'root',
    'daemon' => 'root',
    'dbus' => 'root',
    'decode' => 'root',
    'desktop' => 'root',
    'dovecot' => 'root',
    'dumper' => 'root',
    'fax' => 'root',
    'ftp-adm' => 'ftp',
    'ftpadm' => 'ftp',
    'ftp-admin' => 'ftp',
    'ftpadmin' => 'ftp',
    'ftp' => 'root',
    'games' => 'root',
    'gdm' => 'root',
    'gopher' => 'root',
    'halt' => 'root',
    'hostmaster' => 'root',
    'ident' => 'root',
    'info' => 'postmaster',
    'ingres' => 'root',
    'ldap' => 'root',
    'lp' => 'root',
    'mailnull' => 'root',
    'mail' => 'root',
    'manager' => 'root',
    'marketing' => 'postmaster',
    'mysql' => 'root',
    'named' => 'root',
    'netdump' => 'root',
    'newsadmin' => 'news',
    'newsadm' => 'news',
    'news' => 'root',
    'nfsnobody' => 'root',
    'nobody' => 'root',
    'noc' => 'root',
    'nscd' => 'root',
    'ntp' => 'root',
    'nut' => 'root',
    'operator' => 'root',
    'pcap' => 'root',
    'pcp' => 'root',
    'postfix' => 'root',
    'postgres' => 'root',
    'privoxy' => 'root',
    'pvm' => 'root',
    'quagga' => 'root',
    'radiusd' => 'root',
    'radvd' => 'root',
    'rpc' => 'root',
    'rpcuser' => 'root',
    'rpm' => 'root',
    'sales' => 'postmaster',
    'security' => 'root',
    'shutdown' => 'root',
    'smmsp' => 'root',
    'squid' => 'root',
    'sshd' => 'root',
    'support' => 'postmaster',
    'sync' => 'root',
    'system' => 'root',
    'toor' => 'root',
    'usenet' => 'news',
    'uucp' => 'root',
    'vcsa' => 'root',
    'webalizer' => 'root',
    'webmaster' => 'root',
    'wnn' => 'root',
    'www' => 'webmaster',
    'xfs' => 'root',
  }.each do |key, value|
    its('content') { should match /^#{key}: "#{value}"$/ }
  end
  its('content') { should match /^postmaster:\s+root$/ }
end

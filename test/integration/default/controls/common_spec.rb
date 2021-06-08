control 'postfix-common' do
  describe service 'postfix' do
    it { should be_enabled }
    it { should be_running }
  end

  describe port 25 do
    it { should be_listening }
  end

  describe package 'postfix' do
    it { should be_installed }
  end

  describe command 'journalctl -u postfix' do
    its('stdout') { should_not match /Postfix is running with backwards-compatible default settings/ }
  end

  describe file('/var/log/audit/audit.log') do
    its('content') { should_not match /^type=AVC/ }
  end
end

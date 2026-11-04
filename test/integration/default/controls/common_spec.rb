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

  # postconf -M exits 0 even for a missing service, so match stdout
  describe command 'postconf -M retry/unix' do
    its('stdout') { should match /^retry\s+unix\s.*\serror$/ }
  end

  describe command 'postconf -M proxywrite/unix' do
    its('stdout') { should match /^proxywrite\s+unix\s.*\sproxymap$/ }
  end

  describe command 'postfix check' do
    its('exit_status') { should eq 0 }
  end

  describe file('/var/log/audit/audit.log') do
    its('content') { should_not match /^type=AVC/ }
  end
end

require 'serverspec'

set :backend, :exec

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

describe file('/etc/postfix/main.cf') do
  [
    '# Configured as client',
    /myorigin = \$mydomain/,
    'relayhost = \[smtp.osuosl.org\]:25',
    'smtpd_use_tls = no',
    'smtp_use_tls = no',
  ].each do |line|
    its(:content) { should match(line) }
  end
end

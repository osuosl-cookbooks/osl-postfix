require 'spec_helper'

describe 'postfix' do
  it_behaves_like 'postfix'
end

describe file '/etc/postfix/main.cf' do
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

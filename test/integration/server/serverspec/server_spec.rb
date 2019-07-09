require 'spec_helper'

describe 'postfix' do
  it_behaves_like 'postfix'
end

describe file '/etc/postfix/main.cf' do
  its(:content) { should match(/# Configured as master/) }
end

describe iptables do
  it { should have_rule('-A smtp -p tcp -m tcp --dport 25 -j ACCEPT') }
end

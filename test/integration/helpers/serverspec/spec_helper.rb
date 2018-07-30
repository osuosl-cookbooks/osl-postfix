require 'serverspec'

set :backend, :exec

shared_examples_for 'postfix' do
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
end

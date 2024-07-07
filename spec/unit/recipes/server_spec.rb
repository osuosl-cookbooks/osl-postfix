require_relative '../../spec_helper'

describe 'osl-postfix::server' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      include_context 'common_stubs'

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      case p[:platform]
      when 'almalinux'
        it { is_expected.to install_package('postfix-perl-scripts') }
      end

      %w(pfcat pfdel).each do |f|
        it { is_expected.to create_cookbook_file("/usr/local/sbin/#{f}").with(source: "server/#{f}") }
      end

      it { is_expected.to accept_osl_firewall_port('smtp') }
      it { is_expected.to include_recipe('postfix::server') }

      case p[:platform]
      when 'almalinux'
        it { is_expected.to include_recipe('osl-selinux::default') }
      else
        it { is_expected.to_not include_recipe('osl-selinux::default') }
      end

      it { is_expected.to render_file('/etc/postfix/main.cf').with_content(/# Configured as master/) }
    end
  end
end

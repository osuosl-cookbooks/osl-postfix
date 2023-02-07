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

      if p[:platform] == 'centos' || p[:platform] == 'almalinux'
        it do
          expect(chef_run).to install_package('postfix-perl-scripts')
        end
      end

      %w(pfcat pfdel).each do |f|
        it do
          expect(chef_run).to create_cookbook_file("/usr/local/sbin/#{f}").with(
            source: "server/#{f}"
          )
        end
      end

      it do
        expect(chef_run).to accept_osl_firewall_port('smtp')
      end

      it do
        expect(chef_run).to include_recipe('postfix::server')
      end

      it do
        if p[:platform] == 'centos' || p[:platform] == 'almalinux'
          expect(chef_run).to include_recipe('osl-selinux::default')
        else
          expect(chef_run).to_not include_recipe('osl-selinux::default')
        end
      end

      it do
        expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(/# Configured as master/)
      end
    end
  end
end

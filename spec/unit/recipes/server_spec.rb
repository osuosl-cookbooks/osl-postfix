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

      if p[:platform] == 'centos'
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

      case p
      when DEBIAN_10
        %w(
          firewall::smtp
          postfix::server
        ).each do |recipe|
          it do
            expect(chef_run).to include_recipe recipe
          end
        end
      else
        %w(
          firewall::smtp
          postfix::server
          osl-selinux::default
        ).each do |recipe|
          it do
            expect(chef_run).to include_recipe recipe
          end
        end
      end

      it do
        expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(/# Configured as master/)
      end
    end
  end
end

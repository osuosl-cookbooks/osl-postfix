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

      %w(
        firewall::smtp
        postfix::server
      ).each do |recipe|
        it do
          expect(chef_run).to include_recipe recipe
        end
      end

      it do
        expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(/# Configured as master/)
      end
    end
  end
end

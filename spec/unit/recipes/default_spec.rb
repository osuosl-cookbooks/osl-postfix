require_relative '../../spec_helper'

describe 'osl-postfix::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      include_context 'common_stubs'

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      [
        '# Configured as client',
        'myorigin = $mydomain',
        'relayhost = [smtp.osuosl.org]:25',
        'smtp_use_tls = no',
      ].each do |line|
        it { is_expected.to render_file('/etc/postfix/main.cf').with_content(line) }
      end

      it { is_expected.to render_file('/etc/postfix/main.cf').with_content('compatibility_level = 2') }

      context 'postfix submission port' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.automatic['network']['default_gateway'] = '10.162.136.1'
          end.converge(described_recipe)
        end
        [
          'relayhost = [smtp.osuosl.org]:587',
          'smtp_use_tls = yes',
        ].each do |line|
          it { is_expected.to render_file('/etc/postfix/main.cf').with_content(line) }
        end
        it do
          case p
          when DEBIAN_12
            is_expected.to render_file('/etc/postfix/main.cf').with_content('smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt')
          else
            is_expected.to_not render_file('/etc/postfix/main.cf').with_content('smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt')
          end
        end
      end
      case p
      when DEBIAN_12
        %w(
          postfix::default
        ).each do |recipe|
          it { is_expected.to include_recipe recipe }
        end
      else
        %w(
          postfix::default
          osl-selinux::default
        ).each do |recipe|
          it { is_expected.to include_recipe recipe }
        end
      end
    end
  end
end

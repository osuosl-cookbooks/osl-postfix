require_relative '../../spec_helper'

describe 'osl-postfix::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      before do
        stub_command('/usr/bin/test /etc/alternatives/mta -ef /usr/sbin/sendmail.postfix')
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      [
        '# Configured as client',
        'myorigin = $mydomain',
        'relayhost = [smtp.osuosl.org]:25',
        'smtpd_use_tls = no',
        'smtp_use_tls = no',
      ].each do |line|
        it do
          expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(line)
        end
      end
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
          it do
            expect(chef_run).to render_file('/etc/postfix/main.cf').with_content(line)
          end
        end
      end
      it do
        expect(chef_run).to include_recipe 'postfix'
      end
    end
  end
end

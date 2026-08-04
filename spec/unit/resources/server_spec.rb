require_relative '../../spec_helper'

# See default_spec.rb for why ChefSpec render_file assertions are
# avoided: delayed_action notifications don't fire in ChefSpec, so we
# assert against accumulator state + resource declarations instead.
# Rendered-config behavior is covered by the kitchen integration suites.

describe 'osl_postfix_server' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      step_into :osl_postfix_server, :osl_postfix
      platform p[:platform], p[:version]

      include_context 'common_stubs'

      context 'composed with osl_postfix baseline (typical base-role + promotion)' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix 'default'
              osl_postfix_server 'default'
            end
          end
        end

        let(:state) { chef_run.node.run_state[:osl_postfix]['default'] }

        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end

        it { is_expected.to create_postfix('default') }

        it 'flips state to master mode with use_alias_maps and inet_interfaces=all' do
          expect(state[:mail_type]).to eq('master')
          expect(state[:use_alias_maps]).to eq(true)
          expect(state[:main_settings]).to include('inet_interfaces' => 'all')
        end

        it 'seeds aliases with osl_postfix_system_aliases' do
          expect(state[:aliases]).to include('abuse' => 'root', 'postmaster' => nil).or include('abuse' => 'root')
          expect(state[:aliases].size).to be > 50
        end

        case p[:platform]
        when 'almalinux'
          it { is_expected.to install_package('postfix-perl-scripts') }
          it { is_expected.to include_recipe('osl-selinux::default') }
        else
          it { is_expected.to_not install_package('postfix-perl-scripts') }
          it { is_expected.to_not include_recipe('osl-selinux::default') }
        end

        # SASL packages must land during the normal converge, not in the
        # delayed inner postfix resource, so downstream cookbooks can manage
        # saslauthd (which they enable in recipe order) without the unit file
        # being missing.
        sasl_packages = case p[:platform]
                        when 'almalinux'
                          %w(cyrus-sasl cyrus-sasl-plain ca-certificates)
                        else
                          %w(libsasl2-2 libsasl2-modules ca-certificates)
                        end

        sasl_packages.each do |pkg|
          it { is_expected.to install_package(pkg) }
        end

        %w(pfcat pfdel pftopsenders pfsumm).each do |f|
          it do
            is_expected.to create_cookbook_file("/usr/local/sbin/#{f}").with(
              source: "server/#{f}",
              mode: '755',
              cookbook: 'osl-postfix'
            )
          end
        end

        it { is_expected.to accept_osl_firewall_port('smtp') }
      end

      context 'standalone (no prior osl_postfix call)' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix_server 'default'
            end
          end
        end

        let(:state) { chef_run.node.run_state[:osl_postfix]['default'] }

        it 'still accumulates master state' do
          expect(state[:mail_type]).to eq('master')
          expect(state[:use_alias_maps]).to eq(true)
        end

        it { is_expected.to create_postfix('default') }
        it { is_expected.to accept_osl_firewall_port('smtp') }
      end

      context 'with caller-supplied main_settings' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix 'default'
              osl_postfix_server 'default' do
                main_settings(
                  'smtpd_tls_cert_file' => '/etc/pki/tls/certs/wildcard.pem',
                  'smtpd_use_tls' => 'yes',
                  'smtpd_tls_security_level' => 'may'
                )
              end
            end
          end
        end

        let(:state) { chef_run.node.run_state[:osl_postfix]['default'] }

        it 'merges caller main_settings on top of inet_interfaces=all' do
          expect(state[:main_settings]).to include(
            'inet_interfaces' => 'all',
            'smtpd_tls_cert_file' => '/etc/pki/tls/certs/wildcard.pem',
            'smtpd_use_tls' => 'yes',
            'smtpd_tls_security_level' => 'may'
          )
        end
      end

      context 'with master_settings overriding only one nested field (deep merge regression)' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix 'default'
              osl_postfix_server 'default' do
                master_settings('smtps' => { 'active' => true })
              end
            end
          end
        end

        let(:smtps) { chef_run.node.run_state[:osl_postfix]['default'][:master_settings]['smtps'] }

        it 'deep-merges so caller-set fields override defaults, defaults survive' do
          expect(smtps['active']).to eq(true)         # caller override
          expect(smtps['order']).to eq(30)            # upstream default survived
          expect(smtps['type']).to eq('inet')         # upstream default survived
          expect(smtps['command']).to eq('smtpd')     # upstream default survived
          expect(smtps['args']).to be_a(Array)        # upstream default survived
        end
      end

      context 'no-downgrade guard: osl_postfix called AFTER osl_postfix_server' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix_server 'default'
              osl_postfix 'default' # MUST NOT reset state to client
            end
          end
        end

        let(:state) { chef_run.node.run_state[:osl_postfix]['default'] }

        it 'keeps mail_type=master once promoted' do
          expect(state[:mail_type]).to eq('master')
        end

        it 'keeps use_alias_maps=true once promoted' do
          expect(state[:use_alias_maps]).to eq(true)
        end

        it 'keeps inet_interfaces=all once promoted' do
          expect(state[:main_settings]).to include('inet_interfaces' => 'all')
        end
      end

      context 'with caller-supplied aliases on top of system aliases' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix 'default'
              osl_postfix_server 'default' do
                aliases('alerts' => 'admin@example.com')
              end
            end
          end
        end

        let(:state) { chef_run.node.run_state[:osl_postfix]['default'] }

        it 'merges caller aliases on top of osl_postfix_system_aliases' do
          # caller-supplied entry present
          expect(state[:aliases]).to include('alerts' => 'admin@example.com')
          # system aliases still present
          expect(state[:aliases]).to include('abuse' => 'root', 'webmaster' => 'root')
        end
      end

      context 'when called multiple times (idempotent ancillaries)' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix 'default'
              osl_postfix_server 'default'
              osl_postfix_server 'default' do
                main_settings('message_size_limit' => '102400000')
              end
            end
          end
        end

        let(:state) { chef_run.node.run_state[:osl_postfix]['default'] }

        it 'does not raise on duplicate ancillary resources' do
          expect { chef_run }.to_not raise_error
        end

        it 'last main_settings wins via accumulator merge' do
          expect(state[:main_settings]).to include(
            'message_size_limit' => '102400000',
            'inet_interfaces' => 'all'
          )
        end
      end
    end
  end
end

require_relative '../../spec_helper'

# NOTE: The inner `postfix 'default'` resource is declared with
# `action :nothing` and `delayed_action :create` so multiple osl_postfix*
# calls in one run can layer state via node.run_state before a single
# end-of-run converge. ChefSpec does not fire `:delayed` notifications,
# so `render_file` cannot be used here. We assert against the
# accumulator state (node.run_state[:osl_postfix][name]) and resource
# declarations instead; rendered-content assertions live in kitchen
# (test/integration/...).

describe 'osl_postfix' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      step_into :osl_postfix
      platform p[:platform], p[:version]

      include_context 'common_stubs'

      cached(:chef_run) do
        chef_runner.converge('postfix_test::blank') do
          recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
          recipe.instance_exec do
            osl_postfix 'default'
          end
        end
      end

      let(:state) { chef_run.node.run_state[:osl_postfix]['default'] }

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { is_expected.to create_postfix('default') }

      it 'accumulates client baseline state' do
        expect(state[:mail_type]).to eq('client')
        expect(state[:use_alias_maps]).to eq(false)
      end

      case p
      when *ALL_DEBIAN
        it { is_expected.to_not include_recipe 'osl-selinux::default' }
      else
        it { is_expected.to include_recipe 'osl-selinux::default' }
      end

      context 'with caller-supplied main_settings' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix 'default' do
                main_settings(
                  'mydomain' => 'example.com',
                  'relayhost' => '[smtp.example.com]:2525'
                )
              end
            end
          end
        end

        it 'merges caller main_settings into accumulator state' do
          expect(state[:main_settings]).to include(
            'mydomain' => 'example.com',
            'relayhost' => '[smtp.example.com]:2525'
          )
        end
      end

      context 'with master_settings overriding only one nested field (deep merge regression)' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix 'default' do
                master_settings('submission' => { 'active' => true })
              end
            end
          end
        end

        let(:submission) { state[:master_settings]['submission'] }

        it 'deep-merges so caller fields override but defaults survive' do
          expect(submission['active']).to eq(true)        # caller override
          expect(submission['order']).to eq(20)           # upstream default survived
          expect(submission['type']).to eq('inet')        # upstream default survived
          expect(submission['command']).to eq('smtpd')    # upstream default survived
        end
      end

      context 'with use_*_maps + companion property hashes' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix 'default' do
                use_access_maps true
                access('10.0.0.1' => 'OK')
                use_transport_maps true
                transports('foo@example.com' => 'local:$myhostname')
                use_virtual_aliases true
                virtual_aliases('alias@example.com' => 'real@example.com')
                use_virtual_aliases_domains true
                virtual_aliases_domains('example.org' => '')
                use_relay_restrictions_maps true
                relay_restrictions('example.com' => 'OK')
                maps('hash' => { '/etc/postfix/extra' => { 'key' => 'value' } })
              end
            end
          end
        end

        it 'accumulates all use_*_maps flags' do
          expect(state[:use_access_maps]).to eq(true)
          expect(state[:use_transport_maps]).to eq(true)
          expect(state[:use_virtual_aliases]).to eq(true)
          expect(state[:use_virtual_aliases_domains]).to eq(true)
          expect(state[:use_relay_restrictions_maps]).to eq(true)
        end

        it 'accumulates companion map hashes' do
          expect(state[:access]).to include('10.0.0.1' => 'OK')
          expect(state[:transports]).to include('foo@example.com' => 'local:$myhostname')
          expect(state[:virtual_aliases]).to include('alias@example.com' => 'real@example.com')
          expect(state[:virtual_aliases_domains]).to include('example.org' => '')
          expect(state[:relay_restrictions]).to include('example.com' => 'OK')
          expect(state[:maps]).to include('hash' => { '/etc/postfix/extra' => { 'key' => 'value' } })
        end
      end

      context 'with canonical_map_entries properties' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix 'default' do
                sender_canonical_map_entries(
                  'hosting@osuosl.org' => 'hosting@lists.osuosl.org'
                )
                recipient_canonical_map_entries(
                  'powerdev@osuosl.org' => 'powerdev@lists.osuosl.org'
                )
              end
            end
          end
        end

        it 'accumulates sender_canonical_map_entries into state' do
          expect(state[:sender_canonical_map_entries]).to include(
            'hosting@osuosl.org' => 'hosting@lists.osuosl.org'
          )
        end

        it 'accumulates recipient_canonical_map_entries into state' do
          expect(state[:recipient_canonical_map_entries]).to include(
            'powerdev@osuosl.org' => 'powerdev@lists.osuosl.org'
          )
        end
      end

      context 'with sasl property' do
        cached(:chef_run) do
          chef_runner.converge('postfix_test::blank') do
            recipe = Chef::Recipe.new('test', '_test', chef_runner.run_context)
            recipe.instance_exec do
              osl_postfix 'default' do
                main_settings(
                  'relayhost' => '[smtp.example.com]:587',
                  'smtp_sasl_auth_enable' => 'yes'
                )
                sasl(
                  '[smtp.example.com]:587' => {
                    'username' => 'postfix',
                    'password' => 'secret',
                  }
                )
              end
            end
          end
        end

        it 'accumulates sasl into state' do
          expect(state[:sasl]).to include(
            '[smtp.example.com]:587' => hash_including('username' => 'postfix', 'password' => 'secret')
          )
        end

        it 'caller main_settings still wins for smtp_sasl_auth_enable' do
          expect(state[:main_settings]).to include('smtp_sasl_auth_enable' => 'yes')
        end
      end
    end
  end
end

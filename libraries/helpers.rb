module OslPostfix
  module Cookbook
    module Helpers
      OSL_TLS_PROTOCOLS = %w(!SSLv2 !SSLv3 !TLSv1 !TLSv1.1).freeze
      OSL_TLS_EXCLUDE_CIPHERS = %w(EXP MEDIUM LOW DES 3DES SSLv2).freeze
      OSL_TLS_HIGH_CIPHERLIST = 'kEECDH:+kEECDH+SHA:kEDH:+kEDH+SHA:+kEDH+CAMELLIA:kECDH:+kECDH+SHA:kRSA:+kRSA+SHA:+kRSA+CAMELLIA:!aNULL:!eNULL:!SSLv2:!RC4:!MD5:!DES:!EXP:!SEED:!IDEA:!3DES'.freeze
      OSL_SUBMISSION_GATEWAYS = %w(
        10.162.136.1
        128.193.126.193
        148.100.110.1
        148.100.84.1
        10.6.4.1
      ).freeze

      def osl_postfix_tls_protocols
        OSL_TLS_PROTOCOLS
      end

      def osl_postfix_tls_exclude_ciphers
        OSL_TLS_EXCLUDE_CIPHERS
      end

      def osl_postfix_tls_high_cipherlist
        OSL_TLS_HIGH_CIPHERLIST
      end

      def osl_postfix_hardening_defaults
        tls_protocols = osl_postfix_tls_protocols.join(',')
        exclude_ciphers = osl_postfix_tls_exclude_ciphers.join(',')

        {
          'compatibility_level' => '2',
          'lmtp_tls_mandatory_protocols' => tls_protocols,
          'lmtp_tls_protocols' => tls_protocols,
          'myorigin' => '$mydomain',
          'smtp_tls_ciphers' => 'high',
          'smtp_tls_exclude_ciphers' => exclude_ciphers,
          'smtp_tls_mandatory_protocols' => tls_protocols,
          'smtp_tls_protocols' => tls_protocols,
          'smtp_tls_security_level' => 'may',
          'smtpd_data_restrictions' => 'reject_unauth_pipelining',
          'smtpd_discard_ehlo_keywords' => 'chunking,silent-discard',
          'smtpd_tls_ciphers' => 'high',
          'smtpd_tls_eecdh_grade' => 'strong',
          'smtpd_tls_exclude_ciphers' => exclude_ciphers,
          'smtpd_tls_mandatory_protocols' => tls_protocols,
          'smtpd_tls_protocols' => tls_protocols,
          'smtpd_tls_security_level' => 'none',
          'smtpd_use_tls' => 'no',
          'tls_high_cipherlist' => osl_postfix_tls_high_cipherlist,
          'tlsproxy_tls_mandatory_protocols' => '$smtpd_tls_mandatory_protocols',
          'tlsproxy_tls_protocols' => '$smtpd_tls_protocols',
        }
      end

      def osl_postfix_relayhost_for_gateway
        gateway = node.dig('network', 'default_gateway')
        if OSL_SUBMISSION_GATEWAYS.include?(gateway)
          settings = {
            'relayhost' => '[smtp.osuosl.org]:587',
            'smtp_use_tls' => 'yes',
          }
          settings['smtp_tls_CAfile'] = '/etc/ssl/certs/ca-certificates.crt' if platform_family?('debian')
          settings
        else
          {
            'relayhost' => '[smtp.osuosl.org]:25',
            'smtp_use_tls' => 'no',
          }
        end
      end

      def osl_postfix_state(name)
        node.run_state[:osl_postfix] ||= {}
        node.run_state[:osl_postfix][name] ||= {
          mail_type: 'client',
          main_settings: {},
          master_settings: {},
          aliases: {},
          access: {},
          transports: {},
          virtual_aliases: {},
          virtual_aliases_domains: {},
          relay_restrictions: {},
          maps: {},
          sasl: {},
          sender_canonical_map_entries: {},
          recipient_canonical_map_entries: {},
          use_alias_maps: false,
          use_access_maps: false,
          use_transport_maps: false,
          use_virtual_aliases: false,
          use_virtual_aliases_domains: false,
          use_relay_restrictions_maps: false,
        }
      end

      def osl_postfix_ensure_inner_resource(name)
        return if find_resource(:postfix, name)

        with_run_context(:root) do
          # Recipe-level handle for `service[postfix]`. The upstream postfix
          # resource also declares `service[postfix]` (transitively via
          # postfix_service[postfix]), but that copy lives inside the inner
          # postfix resource's nested run-context and is unreachable from
          # recipe-level `notifies :restart, 'service[postfix]'`. Exposing
          # one here at the root run-context restores the legacy notify
          # target downstream cookbooks expect when they manage their own
          # /etc/postfix/* files alongside the wrapper.
          unless find_resource(:service, 'postfix')
            declare_resource(:service, 'postfix') do
              action :nothing
              supports restart: true, reload: true
            end
          end

          declare_resource(:postfix, name) do
            action :nothing
            delayed_action :create
            mail_type lazy { osl_postfix_state(name)[:mail_type] }
            main_settings lazy {
              osl_postfix_hardening_defaults
                .merge(osl_postfix_relayhost_for_gateway)
                .merge(osl_postfix_state(name)[:main_settings])
            }
            master_settings lazy { osl_postfix_state(name)[:master_settings] }
            aliases lazy { osl_postfix_state(name)[:aliases] }
            access lazy { osl_postfix_state(name)[:access] }
            transports lazy { osl_postfix_state(name)[:transports] }
            virtual_aliases lazy { osl_postfix_state(name)[:virtual_aliases] }
            virtual_aliases_domains lazy { osl_postfix_state(name)[:virtual_aliases_domains] }
            relay_restrictions lazy { osl_postfix_state(name)[:relay_restrictions] }
            maps lazy { osl_postfix_state(name)[:maps] }
            sasl lazy { osl_postfix_state(name)[:sasl] }
            sender_canonical_map_entries lazy { osl_postfix_state(name)[:sender_canonical_map_entries] }
            recipient_canonical_map_entries lazy { osl_postfix_state(name)[:recipient_canonical_map_entries] }
            use_alias_maps lazy { osl_postfix_state(name)[:use_alias_maps] }
            use_access_maps lazy { osl_postfix_state(name)[:use_access_maps] }
            use_transport_maps lazy { osl_postfix_state(name)[:use_transport_maps] }
            use_virtual_aliases lazy { osl_postfix_state(name)[:use_virtual_aliases] }
            use_virtual_aliases_domains lazy { osl_postfix_state(name)[:use_virtual_aliases_domains] }
            use_relay_restrictions_maps lazy { osl_postfix_state(name)[:use_relay_restrictions_maps] }
          end
        end
      end

      def osl_postfix_system_aliases
        # Defaults on RHEL 8
        {
          'abuse' => 'root',
          'adm' => 'root',
          'amandabackup' => 'root',
          'apache' => 'root',
          'bin' => 'root',
          'canna' => 'root',
          'daemon' => 'root',
          'dbus' => 'root',
          'decode' => 'root',
          'desktop' => 'root',
          'dovecot' => 'root',
          'dumper' => 'root',
          'fax' => 'root',
          'ftp-adm' => 'ftp',
          'ftpadm' => 'ftp',
          'ftp-admin' => 'ftp',
          'ftpadmin' => 'ftp',
          'ftp' => 'root',
          'games' => 'root',
          'gdm' => 'root',
          'gopher' => 'root',
          'halt' => 'root',
          'hostmaster' => 'root',
          'ident' => 'root',
          'info' => 'postmaster',
          'ingres' => 'root',
          'ldap' => 'root',
          'lp' => 'root',
          'mailnull' => 'root',
          'mail' => 'root',
          'manager' => 'root',
          'marketing' => 'postmaster',
          'mysql' => 'root',
          'named' => 'root',
          'netdump' => 'root',
          'newsadmin' => 'news',
          'newsadm' => 'news',
          'news' => 'root',
          'nfsnobody' => 'root',
          'nobody' => 'root',
          'noc' => 'root',
          'nscd' => 'root',
          'ntp' => 'root',
          'nut' => 'root',
          'operator' => 'root',
          'pcap' => 'root',
          'pcp' => 'root',
          'postfix' => 'root',
          'postgres' => 'root',
          'privoxy' => 'root',
          'pvm' => 'root',
          'quagga' => 'root',
          'radiusd' => 'root',
          'radvd' => 'root',
          'rpc' => 'root',
          'rpcuser' => 'root',
          'rpm' => 'root',
          'sales' => 'postmaster',
          'security' => 'root',
          'shutdown' => 'root',
          'smmsp' => 'root',
          'squid' => 'root',
          'sshd' => 'root',
          'support' => 'postmaster',
          'sync' => 'root',
          'system' => 'root',
          'toor' => 'root',
          'usenet' => 'news',
          'uucp' => 'root',
          'vcsa' => 'root',
          'webalizer' => 'root',
          'webmaster' => 'root',
          'wnn' => 'root',
          'www' => 'webmaster',
          'xfs' => 'root',
        }
      end
    end
  end
end

Chef::DSL::Recipe.include ::OslPostfix::Cookbook::Helpers
Chef::Resource.include ::OslPostfix::Cookbook::Helpers

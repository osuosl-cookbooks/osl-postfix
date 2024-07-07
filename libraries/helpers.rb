module OslPostfix
  module Cookbook
    module Helpers
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

      def osl_postfix_tls_exclude_ciphers
        %w(EXP MEDIUM LOW DES 3DES SSLv2)
      end

      def osl_postfix_tls_protocols
        %w(!SSLv2 !SSLv3 !TLSv1 !TLSv1.1)
      end

      def osl_postfix_tls_high_cipherlist
        'kEECDH:+kEECDH+SHA:kEDH:+kEDH+SHA:+kEDH+CAMELLIA:kECDH:+kECDH+SHA:kRSA:+kRSA+SHA:+kRSA+CAMELLIA:!aNULL:!eNULL:!SSLv2:!RC4:!MD5:!DES:!EXP:!SEED:!IDEA:!3DES'
      end
    end
  end
end
Chef::DSL::Recipe.include ::OslPostfix::Cookbook::Helpers
Chef::Resource.include ::OslPostfix::Cookbook::Helpers
# Needed to used in attributes/
Chef::Node.include ::OslPostfix::Cookbook::Helpers

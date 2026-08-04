resource_name :osl_postfix_server
provides :osl_postfix_server
unified_mode true

action_class do
  include PostfixCookbook::Helpers
end

property :main_settings, Hash, default: {}
property :master_settings, Hash, default: {}
property :aliases, Hash, default: {}
property :access, Hash, default: {}
property :transports, Hash, default: {}
property :virtual_aliases, Hash, default: {}
property :virtual_aliases_domains, Hash, default: {}
property :relay_restrictions, Hash, default: {}
property :maps, Hash, default: {}
property :sasl, Hash, default: {}
property :sender_canonical_map_entries, Hash, default: {}
property :recipient_canonical_map_entries, Hash, default: {}
property :use_access_maps, [true, false], default: false
property :use_transport_maps, [true, false], default: false
property :use_virtual_aliases, [true, false], default: false
property :use_virtual_aliases_domains, [true, false], default: false
property :use_relay_restrictions_maps, [true, false], default: false

action :create do
  package 'postfix-perl-scripts' if platform_family?('rhel') && !find_resource(:package, 'postfix-perl-scripts')

  # The inner postfix resource converges at the end of the run, so the SASL
  # packages its postfix_sasl_auth sub-resource installs (which ship
  # saslauthd.service) don't exist while recipe-order resources converge.
  # Downstream cookbooks that manage saslauthd themselves need the unit file
  # before then, so install the same package list eagerly here.
  postfix_sasl_packages.each do |pkg|
    package pkg unless find_resource(:package, pkg)
  end

  %w(pfcat pfdel pftopsenders pfsumm).each do |f|
    path = "/usr/local/sbin/#{f}"
    next if find_resource(:cookbook_file, path)

    cookbook_file path do
      source "server/#{f}"
      mode '755'
      cookbook 'osl-postfix'
    end
  end

  osl_firewall_port 'smtp' unless find_resource(:osl_firewall_port, 'smtp')

  state = osl_postfix_state(new_resource.name)

  # Server promotion: forced settings
  state[:mail_type] = 'master'
  state[:use_alias_maps] = true
  state[:main_settings].merge!('inet_interfaces' => 'all').merge!(new_resource.main_settings)

  # Aliases: if no aliases accumulated yet, seed with the OSL system aliases
  state[:aliases] = osl_postfix_system_aliases if state[:aliases].empty?
  state[:aliases].merge!(new_resource.aliases)

  unless new_resource.master_settings.empty?
    state[:master_settings] = postfix_default_master_settings if state[:master_settings].empty?
    state[:master_settings] = Chef::Mixin::DeepMerge.deep_merge(new_resource.master_settings, state[:master_settings])
  end
  state[:access].merge!(new_resource.access)
  state[:transports].merge!(new_resource.transports)
  state[:virtual_aliases].merge!(new_resource.virtual_aliases)
  state[:virtual_aliases_domains].merge!(new_resource.virtual_aliases_domains)
  state[:relay_restrictions].merge!(new_resource.relay_restrictions)
  state[:maps].merge!(new_resource.maps)
  state[:sasl].merge!(new_resource.sasl)
  state[:sender_canonical_map_entries].merge!(new_resource.sender_canonical_map_entries)
  state[:recipient_canonical_map_entries].merge!(new_resource.recipient_canonical_map_entries)

  state[:use_access_maps] ||= new_resource.use_access_maps
  state[:use_transport_maps] ||= new_resource.use_transport_maps
  state[:use_virtual_aliases] ||= new_resource.use_virtual_aliases
  state[:use_virtual_aliases_domains] ||= new_resource.use_virtual_aliases_domains
  state[:use_relay_restrictions_maps] ||= new_resource.use_relay_restrictions_maps

  osl_postfix_ensure_inner_resource(new_resource.name)
end

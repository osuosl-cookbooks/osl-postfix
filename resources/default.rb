resource_name :osl_postfix
provides :osl_postfix
unified_mode true

action_class do
  include PostfixCookbook::Helpers
end

property :mail_type, String, default: 'client', equal_to: %w(client master)
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
property :use_alias_maps, [true, false], default: false
property :use_access_maps, [true, false], default: false
property :use_transport_maps, [true, false], default: false
property :use_virtual_aliases, [true, false], default: false
property :use_virtual_aliases_domains, [true, false], default: false
property :use_relay_restrictions_maps, [true, false], default: false

action :create do
  include_recipe 'osl-selinux' if platform_family?('rhel')

  state = osl_postfix_state(new_resource.name)

  # mail_type: don't downgrade master back to client
  state[:mail_type] = new_resource.mail_type unless state[:mail_type] == 'master'

  state[:main_settings].merge!(new_resource.main_settings)
  unless new_resource.master_settings.empty?
    state[:master_settings] = postfix_default_master_settings if state[:master_settings].empty?
    state[:master_settings] = Chef::Mixin::DeepMerge.deep_merge(new_resource.master_settings, state[:master_settings])
  end
  state[:aliases].merge!(new_resource.aliases)
  state[:access].merge!(new_resource.access)
  state[:transports].merge!(new_resource.transports)
  state[:virtual_aliases].merge!(new_resource.virtual_aliases)
  state[:virtual_aliases_domains].merge!(new_resource.virtual_aliases_domains)
  state[:relay_restrictions].merge!(new_resource.relay_restrictions)
  state[:maps].merge!(new_resource.maps)
  state[:sasl].merge!(new_resource.sasl)
  state[:sender_canonical_map_entries].merge!(new_resource.sender_canonical_map_entries)
  state[:recipient_canonical_map_entries].merge!(new_resource.recipient_canonical_map_entries)

  state[:use_alias_maps] ||= new_resource.use_alias_maps
  state[:use_access_maps] ||= new_resource.use_access_maps
  state[:use_transport_maps] ||= new_resource.use_transport_maps
  state[:use_virtual_aliases] ||= new_resource.use_virtual_aliases
  state[:use_virtual_aliases_domains] ||= new_resource.use_virtual_aliases_domains
  state[:use_relay_restrictions_maps] ||= new_resource.use_relay_restrictions_maps

  osl_postfix_ensure_inner_resource(new_resource.name)
end

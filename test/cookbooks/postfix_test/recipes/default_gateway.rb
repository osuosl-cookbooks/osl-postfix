# Force a recognized OSL submission-only network gateway so the resource's
# gateway-based relayhost helper picks `smtp.osuosl.org:587` + TLS instead
# of the default `:25` plaintext path. The override must hit `automatic`
# precedence because that's where ohai writes node['network'].
node.automatic['network']['default_gateway'] = '10.162.136.1'

osl_postfix 'default'

# OmniAuth.config.logger = Rails.logger
# module OmniAuth
#   class Builder < ::Rack::Builder
#     def provider_patch(klass, *args, &block)
#       @@providers ||= []
#       @@providers << klass
#       old_provider(klass, *args, &block)
#     end
#     alias old_provider provider
#     alias provider provider_patch
#     class << self
#       def providers
#         @@providers
#       end
#     end
#   end
# end

PROVIDERS = YAML.load_file(Rails.root.join('config', 'providers.yaml'))[Rails.env].with_indifferent_access

# Use the system cert store in order to use local certs
Rack::OAuth2.http_config do |http_client|
  http_client.ssl_config.clear_cert_store
  http_client.ssl_config.cert_store.set_default_paths
end

OIDC = lambda do |env|
  # env['omniauth.strategy'].options.merge!(
  #   name: :idpp,
  #   discovery: true,
  #   client_options: {
  #     host: "idp-p.mitre.org",
  #     identifier: PROVIDERS[:idpp][:client_id],
  #     secret: PROVIDERS[:idpp][:client_secret]
  #   }
  # )
  # env['omniauth.strategy'].options[:name] = :idpp
  byebug
  env['omniauth.strategy'].options[:discovery] = true
  env['omniauth.strategy'].options[:client_options] = {
    host:                 "idp-p.mitre.org",
    identifier:           PROVIDERS[:idpp][:client_id],
    private_key:          Application.private_key,
    client_auth_method:   :signed_jwt
  }
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  # provider :openid_connect, name: :idpp, discovery: true, setup: true
  provider :openid_connect, {
    name: :idpp,
    discovery: true,
    setup: true,
    client_options: {
      host:                   "idp-p.mitre.org",
      identifier:             PROVIDERS[:idpp][:client_id],
      grant_type:             'authorization_code',
      client_assertion_type:  'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
      private_key:            Application.private_key
      client_auth_method:     :signed_jwt
    }
  }
end

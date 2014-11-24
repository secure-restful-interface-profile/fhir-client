PROVIDERS = YAML.load_file(Rails.root.join('config', 'providers.yml'))[Rails.env].with_indifferent_access

# Use the system cert store in order to use local certs
Rack::OAuth2.http_config do |http_client|
  http_client.ssl_config.clear_cert_store
  http_client.ssl_config.cert_store.set_default_paths
end

Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :developer unless Rails.env.production?
  # provider :openid_connect, name: :idpp, discovery: true, setup: true
  provider :openid_connect, {
    name:                     :idpp,
    discovery:                true,
    setup:                    true,
    scope:                    [ :openid, :email ],
    
    client_options: {
      host:                   "idp-p.mitre.org",
      identifier:             PROVIDERS[:idpp][:client_id],
      grant_type:             'authorization_code',
      client_assertion_type:  'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
      private_key:            Application.private_key,
      client_auth_method:     "signed_jwt"
    }
  }
end

PROVIDERS = YAML.load_file(Rails.root.join('config', 'providers.yml'))[Rails.env].with_indifferent_access

# Use the system cert store in order to use local certs
Rack::OAuth2.http_config do |http_client|
  http_client.ssl_config.clear_cert_store
  http_client.ssl_config.cert_store.set_default_paths
end

# Provide Omniauth OpenID Connect gem with identity providers we trust
Rails.application.config.middleware.use OmniAuth::Builder do
  IdentityProvider.all.each do |id_provider|
    provider :openid_connect, {
      name:                     id_provider.nickname,
      discovery:                true,
      setup:                    true,
      scope:                    [ :openid, :email ],

      client_options: {
        host:                   id_provider.host,
        identifier:             id_provider.client_id,
        grant_type:             'authorization_code',
        client_assertion_type:  'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
        private_key:            Application.private_key,
        client_auth_method:     'signed_jwt'
      }
    }
  end

  # provider :openid_connect, {
  #   name:                     :idpp,
  #   discovery:                true,
  #   setup:                    true,
  #   scope:                    [ :openid, :email ],
    
  #   client_options: {
  #     host:                   "idp-p.mitre.org",
  #     identifier:             PROVIDERS[:idpp][:client_id],
  #     grant_type:             'authorization_code',
  #     client_assertion_type:  'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
  #     private_key:            Application.private_key,
  #     client_auth_method:     "signed_jwt"
  #   }
  # }

  # provider :openid_connect, {
  #   name:                     :idpva,
  #   discovery:                true,
  #   setup:                    true,
  #   scope:                    [ :openid, :email ],
    
  #   client_options: {
  #     host:                   "idp-va.mitre.org",
  #     identifier:             PROVIDERS[:idpva][:client_id],
  #     grant_type:             'authorization_code',
  #     client_assertion_type:  'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
  #     private_key:            Application.private_key,
  #     client_auth_method:     "signed_jwt"
  #   }
  # }

  # provider :openid_connect, {
  #   name:                     :idper,
  #   discovery:                true,
  #   setup:                    true,
  #   scope:                    [ :openid, :email ],
    
  #   client_options: {
  #     host:                   "idp-er.mitre.org",
  #     identifier:             PROVIDERS[:idper][:client_id],
  #     grant_type:             'authorization_code',
  #     client_assertion_type:  'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
  #     private_key:            Application.private_key,
  #     client_auth_method:     "signed_jwt"
  #   }
  # }

end

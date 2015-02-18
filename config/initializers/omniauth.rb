# Use the system cert store in order to use local certs
Rack::OAuth2.http_config do |http_client|
  http_client.ssl_config.clear_cert_store
  http_client.ssl_config.cert_store.set_default_paths
end

# Configure OmniAuth strategies
Rails.application.config.middleware.use OmniAuth::Builder do

  # Provide OmniAuth OpenID Connect gem with identity providers we trust
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

  # Setup OmniAuth Heart gem with organizations we're dealing with
  Organization.all.each do |organization|
    provider :heart, {
      name:                     organization.nickname,
      discovery:                true,
      setup:                    true,

      client_options: {
        auth_server_uri:        organization.authorization_server_uri,
        client_id:              Application.client_id,
        callback_suffix:        "?org=#{organization.id}",
        jwt_signing_key:        Application.private_key
      }
    }
  end

end

# Setup OmniAuth error handling
OmniAuth.config do |config|
  config.on_failure do
    message = env['omniauth.error.type']
    Rails.logger.error { "/////// OmniAuth Failure: #{message} ///////" }

    redirect_to root_path(:alert => message)
  end
end


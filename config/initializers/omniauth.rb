PROVIDERS = YAML.load_file(Rails.root.join('config', 'providers.yaml'))[Rails.env].with_indifferent_access

# Use the system cert store
Rack::OAuth2.http_config do |http_client|
  http_client.ssl_config.clear_cert_store
  http_client.ssl_config.cert_store.set_default_paths
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :openid_connect, {
    name: :idpp,
    discovery: true,
    client_options: {
      host: "idp-p.mitre.org",
      identifier: PROVIDERS[:idpp][:client_id],
      secret: PROVIDERS[:idpp][:client_secret]
    }
  }
end

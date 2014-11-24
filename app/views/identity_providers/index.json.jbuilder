json.array!(@identity_providers) do |identity_provider|
  json.extract! identity_provider, :id, :name, :uri, :client_id, :registration_client_uri, :registration_access_token, :logo
  json.url identity_provider_url(identity_provider, format: :json)
end

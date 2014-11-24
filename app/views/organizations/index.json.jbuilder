json.array!(@organizations) do |organization|
  json.extract! organization, :id, :name, :resource_server, :authorization_server, :client_id, :registration_client_uri, :registration_access_token, :logo
  json.url organization_url(organization, format: :json)
end

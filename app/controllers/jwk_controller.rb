class JwkController < ApplicationController
  respond_to :json
  def jwk
    pubkey = OpenSSL::PKey::RSA.new File.read Rails.root.join('config', 'client.pub')
    jwk = JSON::JWK.new pubkey
    respond_with JSON::JWK::Set.new(jwk)
  end
end

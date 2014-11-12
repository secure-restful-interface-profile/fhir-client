class JwkController < ApplicationController

  respond_to :json

  def jwk
    Rails.logger.debug "========== Begin JWKS endpoint =========="
    jwk = JSON::JWK.new(Application.public_key)

    jwks = Hash.new
    jwks["keys"] = JSON::JWK::Set.new(jwk)

    Rails.logger.debug "------ JWKS = #{jwks} ------"
    Rails.logger.debug "========== End JWK endpoint =========="

    respond_with jwks
  end

end

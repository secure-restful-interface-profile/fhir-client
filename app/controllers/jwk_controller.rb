class JwkController < ApplicationController

  respond_to :json

  def jwk
    Rails.logger.debug "========== Begin JWKS endpoint =========="
    jwk = JSON::JWK.new(Application.public_key)
    jwks = JSON::JWK::Set.new(jwk)

    Rails.logger.debug "------ JWKS = #{jwks} ------"
    Rails.logger.debug "========== End JWK endpoint =========="
    render json: jwks
  end

end

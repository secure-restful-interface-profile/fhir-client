##
# = JWK Controller
#
# <description>

class JwkController < ApplicationController

  respond_to :json

  #-------------------------------------------------------------------------------

  ##
  # Returns the JSON Web Key Set for the FHIR Client, which includes our public
  # key.

  def jwk
    Rails.logger.debug "========== Begin JWKS endpoint =========="
    
    jwk = JSON::JWK.new(Application.public_key)
    jwks = JSON::JWK::Set.new(jwk)

    Rails.logger.debug "------ JWKS = #{jwks} ------"
    Rails.logger.debug "========== End JWK endpoint =========="

    render json: jwks
  end

end

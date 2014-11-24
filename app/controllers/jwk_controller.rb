##
# = JSON Web Key (JWK) Set Controller
#
# This class manages the jwks_uri API for the FHIR Client.  The /jwk API is 
# generally called when a JSON Web Token (JWT), signed by the FHIR Client's 
# private key, is sent to the authorization server for authentication.  The 
# authorization server uses the public key returned by this API call to decode 
# and authenticate the JWT.

class JwkController < ApplicationController

  respond_to :json

  #-------------------------------------------------------------------------------

  ##
  # GET /jwk
  #
  # Returns the JSON Web Key Set for the FHIR Client, which includes our public
  # key.  The public key is returned as a JWK Set using the following format:
  #
  # {"keys":
  #   [
  #     {"kty":"RSA",
  #      "n": "0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx
  #             4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCiFV4n3oknjhMs
  #             tn64tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65YGjQR0_FDW2
  #             QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n91CbOpbI
  #             SD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINHaQ-G_xBniIqb
  #             w0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw",
  #      "e":"AQAB",
  #      "alg":"RS256",
  #      "kid":"2011-04-29"}
  #   ]
  # }
  #
  # Return:
  #   +JSON+::                JWK set containing public key for the FHIR Client

  def jwk
    Rails.logger.debug "========== Begin JWKS endpoint =========="

    jwk = JSON::JWK.new(Application.public_key)
    jwks = JSON::JWK::Set.new(jwk)

    Rails.logger.debug "------ JWKS = #{jwks} ------"
    Rails.logger.debug "========== End JWK endpoint =========="

    render json: jwks
  end

end

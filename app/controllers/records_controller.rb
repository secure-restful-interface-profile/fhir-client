##
# = Records Controller
#
# <description>

class RecordsController < ApplicationController

  def index
    Rails.logger.debug "======== Enter RecordsController::index ========"
    byebug
    if current_user
      response = resource_server.get("https://ehr-va.mitre.org/test-stub/api/conditions")
      if response == 401
        @state = "#{Time.now.to_i}/#{SecureRandom.hex(18)}"
        auth_response = authorization_server.get auth_server_config["authorization_endpoint"] do |request|
          request.body = {
            "response_type"   => "code",
            "client_id"       => Application.client_id,
            "scope"           => "conditions",
            "redirect_uri"    => "https://localhost:3000/auth_endpoint_callback",
            "state"           => @state                               # Guard against CSRF
          }

          Rails.logger.debug "--------- request.headers = #{request.headers.inspect} ----------"
          Rails.logger.debug "--------- request.body = #{request.body.inspect} ---------"
        end
      end

      Rails.logger.debug "--------- auth_response.headers = #{auth_response.headers.inspect} ----------"
      Rails.logger.debug "--------- auth_response.body = #{auth_response.body} ----------"

      # TODO - Error-handling code...
    end
  end
  
  #-------------------------------------------------------------------------------

  def auth_endpoint_callback
    if params["state"] == @state
      # Get authorization code which we use to get an access token
      code = params["code"]

      token_response = authorization_server.get auth_server_config["token_endpoint"] do |request|
        request.body = {
          "client_id"                 => Application.client_id,
          "client_assertion_type"     => "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          "client_assertion"          => jwt_token(jwt_token_endpoint_claims),
          "code"                      => code
        }

        Rails.logger.debug "--------- request.headers = #{request.headers.inspect} ----------"
        Rails.logger.debug "--------- request.body = #{request.body.inspect} ---------"
      end

      Rails.logger.debug "--------- response.headers = #{token_response.headers.inspect} ----------"
      Rails.logger.debug "--------- response.body = #{token_response.body} ----------"

      # TODO - Error-handling code...

      @state = nil
    else
      # Potential CSRF attack...
    end
  end

  #-------------------------------------------------------------------------------
  private
  #-------------------------------------------------------------------------------

  def resource_server
    byebug
    @resource_server ||= Faraday.new(@resource_uri, :ssl => {:verify => false}) do |builder|
      builder.request   :url_encoded    # Encode request parameters as "www-form-urlencoded"
      builder.response  :logger         # Log request and response to STDOUT
      builder.adapter   :net_http       # Perform requests with Net::HTTP
    end
  end

  #-------------------------------------------------------------------------------

  def authorization_server
    byebug
    @authorization_server ||= Faraday.new(@auth_uri, :ssl => {:verify => false}) do |builder|
      builder.request   :url_encoded    # Encode request parameters as "www-form-urlencoded"
      builder.response  :logger         # Log request and response to STDOUT
      builder.adapter   :net_http       # Perform requests with Net::HTTP
    end
  end

  #-------------------------------------------------------------------------------

  def auth_server_config
    # Get authorization server endpoints and configuration settings
    byebug
    @auth_server_config ||= lambda do |env|
      response = authorization_server.get("#{@auth_server_uri}/.well-known/openid-configuration")
      Rails.logger.debug "------ response from auth server = #{response} ------"
      JSON.parse(response.body)
    end
  end    

  #-------------------------------------------------------------------------------

  ##
  # This method creates a JSON Web Token (JWT) so that we can authenticate with
  # the authorization server.
  #
  # Returns:
  #   ++::                  Signed JSON Web Token

  def jwt_token(claims)
    # Sign our claims with our private key.  The authorization server will 
    # contact our jwks_uri endpoint to get our public key to decode the JWT.

    JWT.encode(claims, Application.private_key, 'RS256')
  end

  #-------------------------------------------------------------------------------

  CLAIM_EXPIRATION = 60         # Expiration in seconds

  ##
  # This method defines the claims for the JSON Web Token (JWT) we use to
  # authenticate with the authorization server.
  #
  # Returns:
  #   +Hash+::              Set of claims for JSON Web Token

  def jwt_auth_endpoint_claims
    now = Time.now.to_i

    {
      iss: Application.client_id,                         # Issuer (Resource Server)
      sub: Application.client_id,                         # Subject of request (Resource Server)
      aud: auth_server_config["authorization_endpoint"],  # Intended audience (Authorization Server)
      iat: now,                                           # Time of issue
      exp: now + CLAIM_EXPIRATION,                        # Expiration time
      jti: "#{now}/#{SecureRandom.hex(18)}",              # Unique ID for request
    }
  end

  #-------------------------------------------------------------------------------

  CLAIM_EXPIRATION = 60         # Expiration in seconds

  ##
  # This method defines the claims for the JSON Web Token (JWT) we use to
  # authenticate with the authorization server.
  #
  # Returns:
  #   +Hash+::              Set of claims for JSON Web Token

  def jwt_token_endpoint_claims
    now = Time.now.to_i

    {
      iss: Application.client_id,                   # Issuer (Resource Server)
      sub: Application.client_id,                   # Subject of request (Resource Server)
      aud: auth_server_config["token_endpoint"],    # Intended audience (Authorization Server)
      iat: now,                                     # Time of issue
      exp: now + CLAIM_EXPIRATION,                  # Expiration time
      jti: "#{now}/#{SecureRandom.hex(18)}",        # Unique ID for request
    }
  end

end
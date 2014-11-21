##
# = AuthorizationServer model
#
# This class manages the interface to the Authorization Server.

class AuthorizationServer

  ##
  # This method initializes a new instance of the AuthorizationServer class and
  # sets up the necessary configurations for the communicating with the server.
  #
  # Params:
  #   +server_uri+::        URI of the authorization server
  #
  # Attributes set:
  #   +@server_uri+::       URI of the authorization server

  def initialize(server_uri, client_id)
    @server_uri   = server_uri
    @client_id    = client_id
  end

  #-------------------------------------------------------------------------------

  ##
  #

  def authorize_path(callback_uri)
    @state = "#{Time.now.to_i}/#{SecureRandom.hex(18)}"      

    configuration["authorization_endpoint"] + "?" +
                        "response_type=code&" +
                        "client_id=#{@client_id}&" + 
                        "redirect_uri=#{callback_uri}&" +
                        "state=#{@state}"
  end

  #-------------------------------------------------------------------------------

  ##
  # Params:
  #   +auth_code+::         Authorization code given to us by authorization server
  #
  # Returns:
  #   +String+::            Access token if successful, otherwise nil

  def get_access_token(auth_code)
    response = connection.post(configuration["token_endpoint"]) do |request|
      request.body = {
        "grant_type"                => "authorization_code",
        "code"                      => auth_code,
        "redirect_uri"              => "http://localhost:3000/auth_endpoint_callback",
        "client_id"                 => @client_id,
        "client_assertion_type"     => "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
        "client_assertion"          => jwt_token(token_endpoint_claims)
      }

      Rails.logger.debug "--------- request.headers = #{request.headers.inspect} ----------"
      Rails.logger.debug "--------- request.body = #{request.body.inspect} ---------"
    end

    Rails.logger.debug "--------- response.headers = #{response.headers.inspect} ----------"
    Rails.logger.debug "--------- response.body = #{response.body} ----------"

    parsed_response = JSON.parse(response.body)
    @access_token = parsed_response["access_token"]

    # TODO - Error-handling code...
  end

  #-------------------------------------------------------------------------------

  ##
  # Get authorization server endpoints and configuration settings.  The 
  # configuration is cached in an instance variable so we don't have to keep
  # asking the server.
  #
  # Returns:
  #   +Hash+::              Hash of endpoints and settings for authorization server

  def configuration
    @configuration ||= get_configuration
  end

  #-------------------------------------------------------------------------------

  def access_token
    @access_token
  end

  #-------------------------------------------------------------------------------
  private
  #-------------------------------------------------------------------------------

  ##
  # Establish a connection object that will be reused during communication 
  # with the authorization server.  The connection is cached in an instance
  # variable.

  def connection
    @connection ||= Faraday.new(@server_uri, :ssl => {:verify => false}) do |builder|
      builder.request   :url_encoded    # Encode request parameters as "www-form-urlencoded"
      builder.response  :logger         # Log request and response to STDOUT
      builder.adapter   :net_http       # Perform requests with Net::HTTP
    end
  end

  #-------------------------------------------------------------------------------

  ##
  # Calls the authorization server to retrieve its endpoints and configuration
  # settings.
  #
  # Returns:
  #   +Hash+::              Hash of endpoints and settings for authorization server

  def get_configuration
    Rails.logger.debug "------ Calling .well-known/openid_configuration ------"

    response = connection.get("#{@server_uri}/.well-known/openid-configuration")
    if response.status == 200
      JSON.parse(response.body)
    else
      # TODO Error handling
    end
  end

  #-------------------------------------------------------------------------------

  ##
  # This method creates a JSON Web Token (JWT) so that we can authenticate with
  # the authorization server.
  #
  # Returns:
  #   +String+::            Signed JSON Web Token

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

  def token_endpoint_claims
    now = Time.now.to_i

    {
      iss: @client_id,                              # Issuer (FHIR Client)
      sub: @client_id,                              # Subject of request (FHIR Client)
      aud: configuration["token_endpoint"],         # Intended audience (Authorization Server)
      iat: now,                                     # Time of issue
      exp: now + CLAIM_EXPIRATION,                  # Expiration time
      jti: "#{now}/#{SecureRandom.hex(18)}",        # Unique ID for request
    }
  end

end

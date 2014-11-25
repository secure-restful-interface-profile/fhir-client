##
# = AuthorizationServer model
#
# This class manages the interface to the Authorization Server.

class AuthorizationServer

  ##
  # Initializes a new instance of the AuthorizationServer class and sets up the 
  # necessary configurations for the communicating with the server endpoints.
  #
  # Params:
  #   +server_uri+::            URI of the authorization server
  #   +client_id+::             ID from registration with authorization server 

  def initialize(server_uri, client_id)
    @server_uri   = server_uri
    @client_id    = client_id
  end

  #-------------------------------------------------------------------------------

  ##
  # Creates the URI to access the authorization server's authorization endpoint
  # with the appropriate parameters (e.g. client ID).  The client ID was provided 
  # when we registered the client with the authorization server.
  #
  # A random state is also passed along as part of the URI to help us ensure that 
  # further communication for this authorization is not due to a CSRF attack.
  #
  # Params:
  #   +callback_uri+::          Client URI to call on completion
  #
  # Returns:
  #   +String+::                Path and parameters to get authorization code

  def authorize_path(callback_uri)
    state = "#{Time.now.to_i}/#{SecureRandom.hex(18)}"
    cache_write("state", state)      

    configuration["authorization_endpoint"] + "?" +
                        "response_type=code&" +
                        "client_id=#{@client_id}&" + 
                        "redirect_uri=#{callback_uri}&" +
                        "state=#{state}"
  end

  #-------------------------------------------------------------------------------

  ##
  # Requests a new access token from the authorization server.
  # 
  # We have received the redirect callback from the authorization server with an 
  # authorization code.  Now we issue another request to the authorization with 
  # that code to get an access token, this time with a JSON Web Token signed with 
  # our private key.  We need the access token to retrieve information from the 
  # protected resource server.
  #
  # Params:
  #   +request_from_server+::   Request from server on authorization completion
  #   +callback_uri+::          Must match callback for authorization code
  #
  # Returns:
  #   +String+::                Access token if successful, otherwise nil

  def request_access_token(request_from_server, callback_uri)
    Rails.logger.debug "========= Entering AuthorizationServer::request_access_token ========="

    if valid_state?(request_from_server.params["state"])
      Rails.logger.debug "--------- State is valid ---------"

      response = connection.post(configuration["token_endpoint"]) do |request|
        request.body = {
          "grant_type"                => "authorization_code",
          "code"                      => request_from_server.params["code"],
          "redirect_uri"              => callback_uri,
          "client_id"                 => @client_id,
          "client_assertion_type"     => "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          "client_assertion"          => jwt_token(token_endpoint_claims)
        }

        Rails.logger.debug "--------- request.headers = #{request.headers.inspect} ----------"
        Rails.logger.debug "--------- request.body = #{request.body.inspect} ---------"
      end

      Rails.logger.debug "--------- response.headers = #{response.headers.inspect} ----------"
      Rails.logger.debug "--------- response.body = #{response.body} ----------"

      if OK == response.status
        parsed_response = JSON.parse(response.body)
        parsed_response["access_token"]
      else
        raise "Call to get access token from authorization server failed. #{response.inspect}"
      end
    else
      # Log, but ignore potential CSRF attacks
      Rails.logger.warn "///////// State is invalid - possible CSRF attack /////////"
    end
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
    cache_read("configuration") || get_configuration
  end

  #-------------------------------------------------------------------------------

  ##
  # Retrieves the current access token we received from the authorization server.
  # If this access token has expired, it can be either refreshed or we can get
  # a new access token.
  #
  # Returns:
  #   +String+::            Access token

  def access_token(session)
    session["access_token"]
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
  # settings.  We store the configuration in the cache for future requests.
  #
  # Returns:
  #   +Hash+::              Hash of endpoints and settings for authorization server

  def get_configuration
    Rails.logger.debug "------ Calling .well-known/openid_configuration ------"

    response = connection.get("#{@server_uri}/.well-known/openid-configuration")
    if OK == response.status
      configuration = JSON.parse(response.body)
      cache_write("configuration", configuration)
      configuration
    else
      raise "Could not get configuration from authorization server. #{response.inspect}"
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

  #-------------------------------------------------------------------------------

  ##
  # Determines whether the random state value we passed during the authorization 
  # code phase of the OAuth2 process matches the state value sent with subsequent 
  # requests.
  #
  # Params:
  #   +state+::           State value received during callbacks.
  #
  # Returns:
  #   +Boolean+::         true if state values match, otherwise false.

  def valid_state?(state)
    cache_read("state") == state
  end

  #-------------------------------------------------------------------------------

  ##
  # Reads a value from the cache with the specified key.  
  #
  # The key is augmented with other information to distinguish it from other 
  # authorization servers and clients.
  #
  # Params:
  #   +key+::             Preliminary key for the value.
  #
  # Returns:
  #   +various+::         Value from the cache associated with the key

  def cache_read(key)
    Rails.cache.read(cache_key(key))
  end

  #-------------------------------------------------------------------------------

  ##
  # Writes a value into the cache with the specified key.  
  #
  # The key is augmented with other information to distinguish it from other 
  # authorization servers and clients.
  #
  # Params:
  #   +key+::             Preliminary key for the value.
  #   +value+::           Value to cache.
  #
  # Returns:
  #   +Boolean+::         true if successfully written, otherwise false

  def cache_write(key, value)
    Rails.cache.write(cache_key(key), value)
  end

  #-------------------------------------------------------------------------------

  ##
  # Generates a cache key for storing values related to this server and client.
  #
  # Params:
  #   +name+::            Name of the value.
  #
  # Returns:
  #   +String+::          Cache key for the value.

  def cache_key(name)
    "#{@server_uri}-#{@client_id}-#{name}"
  end

end

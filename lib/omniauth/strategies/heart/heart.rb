require 'omniauth'

module OmniAuth
  module Strategies

    #include AuthorizationServer

    class Heart

      include OmniAuth::Strategy

      args [ :request, :auth_server_uri, :callback_url ]

      #---------------------------------------------------------------------------

      ##
      # Establish a connection with the specified authorization server.
      
      def setup_phase
        @authorization_server = AuthorizationServer.new(options.auth_server_uri)
        super
      end

      #---------------------------------------------------------------------------

      ##
      # The request to the resource server was unauthorized, so we redirect the
      # request to authorization server to get an authorization code.  
      #
      # If successful, the callback URL we provide will be called by the 
      # authorization server with the authorization code.
      
      def request_phase
        Rails.logger.debug "====== Entering Heart::request_phase ======"

        authorize_path = @authorization_server.authorize_path(options.callback_url)
        Rails.logger.debug "------ Redirecting to: #{authorize_path} ------"
        redirect_to(authorize_path)
      end

      #---------------------------------------------------------------------------

      ##
      # Called when the authorization server grants us an authorization code.  With
      # the authorization code, we make another call to the authorization server to
      # request an access token.  We need the access token to access resources from
      # the resource server.
      #
      # Once we successfully have the access token, we redirect back to retry the
      # request with the new access token.

      def callback_phase
        Rails.logger.debug "====== Entering Heart::callback_phase ======"

        session["access_token"] = @authorization_server.
                                      request_access_token(request, 
                                                              options.callback_url)

        # Retry the original request
        redirect_to(options.request)
      end

      #-------------------------------------------------------------------------------

      class AuthorizationServer

        attr_accessor   :uri, :connection, :configuration

        #-------------------------------------------------------------------------------
       
        ##
        # Initializes a new instance of the AuthorizationServer class and sets up the 
        # necessary configurations for the communicating with the server.
        #
        # Params:
        #   +auth_server_uri+::   URI of the authorization server
        #   +rsrc_server_uri+::   URI of protected resource server
        #
        # Attributes set:
        #   +@uri+::              URI of the authorization server
        #   +@connection+::       Connection object to be used for further communication
        #   +@configuration+::    Hash of server capabilities and endpoints

        def initialize(auth_server_uri, rsrc_server_uri)
          @auth_server_uri = auth_server_uri
          @rsrc_server_uri = rsrc_server_uri

          Rails.logger.debug "========== @auth_server_uri = " + @auth_server_uri + "=========="
          Rails.logger.debug "========== @rsrc_server_uri = " + @rsrc_server_uri + "=========="

          # Establish a connection object that will be reused during communication 
          # with the authorization server

          @connection = Faraday.new(@auth_uri, :ssl => {:verify => false}) do |builder|
            builder.request     :url_encoded    # Encode request parameters as "www-form-urlencoded"
            builder.response    :logger         # Log request and response to STDOUT
            builder.adapter     :net_http       # Perform requests with Net::HTTP
          end

          # Get authorization server endpoints and configuration settings
          response = @connection.get("#{@auth_server_uri}/.well-known/openid-configuration")
          @configuration = JSON.parse(response.body)
        end

        #-------------------------------------------------------------------------------
       
        ##
        # Retrieves the public key for the authorization server from the authorization 
        # server's jwks_uri endpoint.
        #
        # Returns:
        #   +String+::            Public key for Authorization Server

        def public_key
          # The public key is provided as a JSON Web Key Set (JWKS) by the jwks_uri 
          # endpoint of the Authorization Server.

          response = @connection.get(@configuration["jwks_uri"])
          jwks = JSON.parse(response.body)

          # Use only first key returned and retrieve the "n" field of that key
          jwks["keys"].first["n"]
        end

        #-------------------------------------------------------------------------------
       
        ##
        # Determines whether the access token provided by the client is valid.
        # To validate the token, the introspection endpoint of the authorization server
        # is called to retrieve the claims for the access token.  Once we have the claims,
        # we can validate whether data request falls within those claims.
        #
        # Params:
        #   +client_request+::    Request hash from the client requesting information
        #
        # Returns:  
        #   +AuthorizedUser+::    Authorized user matching user_id, otherwise nil

        def authorize_request(client_request, test = false)
          # Get access token from client request
          authorization = client_request.env["HTTP_AUTHORIZATION"]
          Rails.logger.debug "--------- authorization = #{authorization} ----------"

          if authorization
            authorization = authorization.split(' ')
            if authorization.first == 'Bearer'
              access_token = authorization.last
            end

            Rails.logger.debug "********** Request = #{client_request.inspect} **********"
            Rails.logger.debug "////////// Access token = #{access_token.inspect} //////////"

            # Call authorization server to perform introspection on access token
            auth_response = @connection.post @configuration["introspection_endpoint"] do |request|
              # Pass access token as form data
              request.body = { 
                "client_id"             => Application.client_id, 
                "client_assertion_type" => "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
                "client_assertion"      => jwt_token, 
                "token"                 => access_token 
              }.to_param

              Rails.logger.debug "--------- request.headers = " + request.headers.inspect + " ----------"
              Rails.logger.debug "--------- request.body = " + request.body.inspect + " ---------"
            end

            Rails.logger.debug "--------- auth_response = " + auth_response.inspect + " ----------"
            Rails.logger.debug "--------- auth_response.body = " + auth_response.body + " ----------"

            if test
              return auth_response
            else
              # Use introspection info to determine validity of access token for request
              validate_access_token(client_request, auth_response)
            end
          else
            # No access token
            nil
          end
        end

        #-------------------------------------------------------------------------------
        private
        #-------------------------------------------------------------------------------

        ##
        # Creates a JSON Web Token (JWT) so that we can authenticate with the 
        # authorization server.
        #
        # Returns:
        #   ++::                  Signed JSON Web Token

        def jwt_token
          # Sign our claims with our private key.  The authorization server will 
          # contact our jwks_uri endpoint to get our public key to decode the JWT.

          JWT.encode(jwt_claims, Application.private_key, 'RS256')
        end

        #-------------------------------------------------------------------------------

        CLAIM_EXPIRATION = 60        # Expiration in seconds

        ##
        # Defines the claims for the JSON Web Token (JWT) we use to authenticate with 
        # the authorization server.
        #
        # Returns:
        #   +Hash+::              Set of claims for JSON Web Token

        def jwt_claims
          now = Time.now.to_i

          {
            iss: Application.client_id,               # Issuer (client ID from auth server)
            sub: Application.client_id,               # Subject of request (client ID from auth server)
            aud: "#{@auth_server_uri}/token",         # Intended audience (Authorization Server)
            iat: now,                                 # Time of issue
            exp: now + CLAIM_EXPIRATION,              # Expiration time
            jti: "#{now}/#{SecureRandom.hex(18)}",    # Unique ID for request
          }
        end

        #-------------------------------------------------------------------------------

        ##
        # Validates the access token passed to us by the client by checking the type of 
        # information allowed by the access token and and verifying that the request is 
        # consistent with those claims.
        #
        # If the token is invalid, :unauthorized is returned.  If a matching authorized 
        # user cannot be found, :forbidden is returned.
        #
        # Params:
        #   +client_request+::    Original request from the client seeking access
        #   +auth_response+::     Response from the Authorization Server introspection
        #
        # Returns:  
        #   +Result+::            Result code (:ok, :unauthorized, :forbidden)
        #   +AuthorizedUser+::    Authorized user matching user_id, otherwise nil

        def validate_access_token(client_request, auth_response)
          authorized_user = nil
          result = :ok
          good_scope = false

          if good = (auth_response.status == 200)
            token_claims = JSON.parse(auth_response.body)

            # Authorize request based on claims of access token
            good = token_claims["active"]
            good = validate_expiration(token_claims)                    if good
            good_scope = validate_scope(client_request, token_claims)   if good
            good, authorized_user = validate_user(token_claims)         if good && good_scope
          end

          result = :forbidden      unless good_scope
          result = :unauthorized   unless good

          Rails.logger.debug "----- valid_access_token? = #{result.to_s} -----"
          return result, authorized_user
        end

        #-------------------------------------------------------------------------------
       
        ##
        # Determines whether the access token has expired based on the expiration
        # time included in the token.
        #
        # Params:
        #   +token_claims+::      Claims from access token introspection
        #
        # Returns:
        #   +boolean+::           +true+ if token has not expired, otherwise +false+

        def validate_expiration(token_claims)
          if token_claims["exp"].blank?
            Rails.logger.debug "----- no expiration time provided in access token -----"
            true
          else
            Rails.logger.debug "----- token_claims['exp'] = #{token_claims["exp"].inspect} -----"
            (token_claims["exp"] >= Time.now.to_i)
          end
        end

        #-------------------------------------------------------------------------------
       
        ##
        # Determines whether the scope of the access token covers the resources
        # specified in the request.  If the request specifies resources that are 
        # not listed within the scope of the access token, the scope is invalid.
        #
        # Params:
        #   +client_request+::    Original request from the client seeking access
        #   +token_claims+::      Claims from access token introspection
        #
        # Returns:
        #   +boolean+::           +true+ if request within token scope, otherwise +false+

        def validate_scope(client_request, token_claims)
          claims = token_claims["scope"].split(' ')

          Rails.logger.debug "----- claims = #{claims.inspect} -----"
          Rails.logger.debug "----- client_request = #{client_request.inspect} -----"

          uri = URI(client_request.fullpath)

          # Parse path to get resource name
          resource = uri.path.split('/').last
          resource = resource.split('.').first if uri.path.include?('.')

          Rails.logger.debug "----- resource = #{resource.inspect} -----"

          claims.include?(resource)
        end

        #-------------------------------------------------------------------------------
       
        ##
        # Validates the user_id returned by the token claims in the authorization server 
        # introspection by ensuring that a matching authorized user exists in our 
        # database.
        #
        # The user_id from the authorization server is treated as an opaque value (even
        # if it may appear to have valuable subfields) to maximize compatibility across
        # authorization server implementations.
        #
        # The list of authorized users in the Test Stub database must be setup ahead of 
        # time.
        #
        # Params:
        #   +token_claims+::      Claims from access token introspection
        #
        # Returns:  
        #   +Boolean+::           +true+ if user matches user_id, otherise false
        #   +AuthorizedUser+::    Authorized user matching user_id, otherwise nil

        def validate_user(token_claims)
          authorized_user = AuthorizedUser.find_by(
                                          auth_server_user_id: token_claims["user_id"])
          return !authorized_user.nil?, authorized_user
        end

      end
    end

  end
end


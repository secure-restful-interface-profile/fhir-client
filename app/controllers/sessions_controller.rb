##
# = Sessions Controller
#
# This class manages user sign-in and sign-out using a chosen identity provider.
# It works in conjunction with the OmniAuth, OmniAuth OpenID Connect, and 
# Rack-OAuth2 gems to perform the authentication.

class SessionsController < ApplicationController

  before_filter   :require_signin, :except => [ :new, :create ]

  #-------------------------------------------------------------------------------

  ##
  # GET /signin
  #
  # Provides the list of identity providers to choose from to signin.

  def new
    @identity_providers = IdentityProvider.all

    if @identity_providers.size > 0
      render
    else
      redirect_to root_path, 
                  alert: "Sorry, but no trusted identity providers are available."
    end
  end

  #-------------------------------------------------------------------------------

  ##
  # GET /auth/:provider/callback
  #
  # Acts as the callback routine from Omniauth at the completion of an 
  # authentication.

  def create
    Rails.logger.debug "========== Begin callback redirection from Omniauth =========="

    id_providers = IdentityProvider.all.map { |id_provider| id_provider.nickname }
    if id_providers.include?(param[:provider])
      create_id_provider_session
    else
      organization = Organization.all.select do |org| 
        org.nickname == param[:provider]
      end
      retry_request_with_access_token(organization) unless organization.nil?
    end
  end

  #-------------------------------------------------------------------------------

  ##
  # GET /auth/:provider/setup
  
  def setup
    Rails.logger.debug "========== Begin setup =========="

    options = request.env['omniauth.strategy'].options

    Rails.logger.debug "------ private_key = #{Application.private_key} ------"

    jws = jwt_token(options)
    Rails.logger.debug "------ jws = #{jws} ------"

    options[:client_options][:client_assertion] = jws
    Rails.logger.debug "------ omniauth.strategy = #{request.env['omniauth.strategy'].options.inspect} ------"

    render :text => "Omniauth setup phase.", :status => 200

    Rails.logger.debug "========== End setup =========="
  end

  #-------------------------------------------------------------------------------

  ##
  # DELETE /signout
  #
  # Clears out the session information, effectively signing the user out.

  def destroy
    session[:email]     = nil

    redirect_to root_url, notice: "Signed out!"
  end

  #-------------------------------------------------------------------------------
  private
  #-------------------------------------------------------------------------------

  ##
  # Creates and initializes the session for signin.  Information about the user 
  # is provided as part of the callback request, which we store in the session 
  # variable.

  def create_id_provider_session
    Rails.logger.debug "========== Create ID provider session =========="

    %w(auth origin params strategy).each do |attribute|
      Rails.logger.debug "------ #{attribute}, #{request.env["omniauth.#{attribute}"].inspect} ------"
    end

    omniauth = request.env['omniauth.auth']
    Rails.logger.debug "------ omniauth = #{omniauth.inspect} ------"

    # Save the email returned by the identity provider to display logged in user
    session[:email]     = omniauth['info']['email']
    Rails.logger.debug "------ email = #{omniauth['info']['email']} ------"

    Rails.logger.debug "========== End callback redirection from identity provider =========="

    redirect_to root_url, notice: "Signed in!"
  end

  #-------------------------------------------------------------------------------

  ##
  # Saves access token returned by authorization server, which we store in a 
  # session variable, and retries the request to retrieve the records from the
  # specified organization.
  #
  # Params:
  #   +organization++       Organization to retrieve records from

  def retry_request_with_access_token(organization)
    Rails.logger.debug "========== Handle auth server callback =========="
    
    omniauth = request.env['omniauth.auth']
    Rails.logger.debug "------ omniauth = #{omniauth.inspect} ------"

    # Save the access token returned by the authorization server for subsequent requests
    session[:access_token] = omniauth['credentials']['access_token']
    Rails.logger.debug "------ access_token = #{omniauth['credentials']['access_token']} ------"

    Rails.logger.debug "------ Redirecting to #{organization_records_path(organization..id)} ------"
    redirect_to organization_records_path(organization.id)
  end

  #-------------------------------------------------------------------------------

  ##
  # This method creates a JSON Web Token (JWT) so that we can authenticate with
  # the authorization server.
  #
  # Params:
  #   +options+::           Claim options for web token (e.g. intended audience)
  #
  # Returns:
  #   +JSON::JWT+::         Signed JSON Web Token

  def jwt_token(options)
    # Sign our claims with our private key.  The authorization server will 
    # contact our jwks_uri endpoint to get our public key to decode the JWT.

    JSON::JWT.new(jwt_claims(options)).sign(Application.private_key, 'RS256')
  end

  #-------------------------------------------------------------------------------

  CLAIM_EXPIRATION = 60         # Expiration in seconds

  ##
  # This method defines the claims for the JSON Web Token (JWT) we use to
  # authenticate with the authorization server.
  #
  # Params:
  #   +options+::           Claim options for web token (e.g. intended audience)
  #
  # Returns:
  #   +Hash+::              Set of claims for JSON Web Token

  def jwt_claims(options)
    now = Time.now.to_i

    {
      iss: Application.client_id,                   # Issuer (Client app)
      sub: Application.client_id,                   # Subject of request (Client app)
      aud: options[:host],                          # Intended audience (Personal Identity Provider)
      iat: now,                                     # Time of issue
      exp: now + CLAIM_EXPIRATION,                  # Expiration time
      jti: "#{now}/#{SecureRandom.hex(18)}"         # Unique ID for request
    }
  end

end

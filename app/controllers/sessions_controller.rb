##
# = Sessions Controller
#
# <description>

class SessionsController < ApplicationController #ActionController::Base

  # layout "application"

  #-------------------------------------------------------------------------------

  # def index
  #   @authentications = current_user.authentications if current_user
  # end

  #-------------------------------------------------------------------------------

  ##
  #

  def new
    @identity_providers = IdentityProvider.all
  end

  #-------------------------------------------------------------------------------

  ##
  #

  def create
    Rails.logger.debug "========== Begin callback redirection from identity provider =========="

    %w(auth origin params strategy).each do |x|
      Rails.logger.debug "------ #{x}, #{request.env["omniauth.#{x}"].inspect} ------"
    end

    omniauth = request.env['omniauth.auth']
    Rails.logger.debug "------ omniauth = #{omniauth.inspect} ------"

    #user = user_from_omniauth(omniauth)
    #session[:user_id] = user.id
    session[:user_id] = omniauth['uid']

    Rails.logger.debug "========== End callback redirection from identity provider =========="

    redirect_to root_url, notice: "Signed in!"
  end

  #-------------------------------------------------------------------------------

  ##
  #
  
  def setup
    Rails.logger.debug "========== Begin setup =========="

    options = request.env['omniauth.strategy'].options

    # byebug
    Rails.logger.debug "------ private_key = #{Application.private_key} ------"

    jws = jwt_token(options)
    Rails.logger.debug "------ jws = #{jws} ------"

    options[:client_options][:client_assertion] = jws
    Rails.logger.debug "------ omniauth.strategy = #{request.env['omniauth.strategy'].options.inspect} ------"

    render :text => "Omniauth setup phase.", :status => 200

    Rails.logger.debug "========== End setup =========="
  end

  #-------------------------------------------------------------------------------

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end

  #-------------------------------------------------------------------------------
  protected
  #-------------------------------------------------------------------------------

  # This is necessary since Rails 3.0.4
  # See https://github.com/intridea/omniauth/issues/185
  # and http://www.arailsdemo.com/posts/44
  # def handle_unverified_request
  #   true
  # end

  #-------------------------------------------------------------------------------
  private
  #-------------------------------------------------------------------------------

  ##
  # This method creates a JSON Web Token (JWT) so that we can authenticate with
  # the authorization server.
  #
  # Returns:
  #   ++::                  Signed JSON Web Token

  def jwt_token(options)
    # Sign our claims with our private key.  The authorization server will 
    # contact our jwks_uri endpoint to get our public key to decode the JWT.

    #JWT.encode(jwt_claims, Application.private_key, 'RS256')
    JSON::JWT.new(jwt_claims(options)).sign(Application.private_key, 'RS256')
  end

  #-------------------------------------------------------------------------------

  CLAIM_EXPIRATION = 60         # Expiration in seconds

  ##
  # This method defines the claims for the JSON Web Token (JWT) we use to
  # authenticate with the authorization server.
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
      jti: "#{now}/#{SecureRandom.hex(18)}",        # Unique ID for request
    }
  end

  #-------------------------------------------------------------------------------
 
  # def user_from_omniauth(auth)
  #   Rails.logger.debug "--- auth.slice(...) = #{auth.slice("provider", "uid")} ---"
  #   User.where(auth.slice("provider", "uid")).first #  || create_from_omniauth(auth)
  # end

  #-------------------------------------------------------------------------------
 
  # def create_from_omniauth(auth)
  #   raw_parameters = {
  #     :provider => auth["provider"],
  #     :uid => auth["uid"],
  #     :name => auth["info"]["nickname"]
  #   }
  #   parameters = ActionController::Parameters.new(raw_parameters)
  #   User.create!(parameters.permit(:provider, :uid, :name))
  # end
  
end

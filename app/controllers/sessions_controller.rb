##
# = Authentications Controller
#
# <description>

class SessionsController < ActionController::Base

  # layout "application"

  #-------------------------------------------------------------------------------

  # def index
  #   @authentications = current_user.authentications if current_user
  # end

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
    session[:user_id] = omniauth['provider'].to_s + omniauth['uid']

    Rails.logger.debug "========== End callback redirection from identity provider =========="

    redirect_to root_url, notice: "Signed in!"

    # authentication = Authentication.where(provider: omniauth['provider'], uid: omniauth['uid']).first

    # if authentication
    #   AuditLog.create(requester_info: authentication.user, event: "user_auth", description: "successful sign in")
    #   flash[:notice] = "Signed in successfully."
    #   sign_in_and_redirect(:user, authentication.user)
    # elsif current_user
    #   current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
    #   AuditLog.create(requester_info: current_user.email, event: "user_auth2", description: "successful sign in")
    #   flash[:notice] = "Authentication successful."
    #   redirect_to authentications_url
    # else
    #   user = User.new
    #   user.apply_omniauth(omniauth)
    #   if user.save
    #     user.authentications[0].save
    #     AuditLog.create(requester_info: user.email, event: "user_auth3", description: "successful account create and sign in")
    #     flash[:notice] = "Signed in successfully."
    #     sign_in_and_redirect(:user, user)
    #   else
    #     session[:omniauth] = omniauth.except('extra')
    #     redirect_to new_user_registration_url
    #   end
    # end
  end

  #-------------------------------------------------------------------------------

  ##
  #
  
  def setup
    Rails.logger.debug "========== Begin setup =========="

    # byebug
    Rails.logger.debug "------ private_key = #{Application.private_key} ------"

    jws = jwt_token
    Rails.logger.debug "------ jws = #{jws} ------"

    request.env['omniauth.strategy'].options[:client_options][:client_assertion] = jws
    Rails.logger.debug "------ omniauth.strategy = #{request.env['omniauth.strategy'].options.inspect} ------"

    render :text => "Omniauth setup phase.", :status => 200

    Rails.logger.debug "========== End setup =========="
  end

  #-------------------------------------------------------------------------------

  # def destroy
  #   @authentication = current_user.authentications.find(params[:id])
  #   @authentication.destroy
  #   flash[:notice] = "Successfully destroyed authentication."
  #   redirect_to authentications_url
  # end

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

  def jwt_token
    # Sign our claims with our private key.  The authorization server will 
    # contact our jwks_uri endpoint to get our public key to decode the JWT.

    #JWT.encode(jwt_claims, Application.private_key, 'RS256')
    JSON::JWT.new(jwt_claims).sign(Application.private_key, 'RS256')
  end

  #-------------------------------------------------------------------------------

  CLAIM_EXPIRATION = 60         # Expiration in seconds

  ##
  # This method defines the claims for the JSON Web Token (JWT) we use to
  # authenticate with the authorization server.
  #
  # Returns:
  #   +Hash+::              Set of claims for JSON Web Token

  def jwt_claims
    now = Time.now.to_i

    {
      iss: Application.client_id,                   # Issuer (Client app)
      sub: Application.client_id,                   # Subject of request (Client app)
      aud: "https://idp-p.mitre.org/token",         # Intended audience (Personal Identity Provider)
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

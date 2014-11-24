##
# = Records Controller
#
# <description>

class RecordsController < ApplicationController

  ##
  # GET /organizations/1/records
  # GET /organizations/1/records.json
  #
  # Retrieves the patient record from the resource server.
  
  def index
    Rails.logger.debug "======== Enter RecordsController::index ========"

    @organization = Organization.find(params[:organization_id])

    @conditions     = get_resource("conditions")
    #@medications    = get_resource("medications")
    #@encounters     = get_resource("encounters")
    #@observations   = get_resource("observations")
  end
  
  #-------------------------------------------------------------------------------

  ##
  # GET /auth_endpoint_callback
  #
  # Called when the authorization server grants us an authorization code.  With
  # the authorization code, we make another call to the authorization server to
  # request an access token.  We need the access token to access resources from
  # the resource server.
  #
  # Once we successfully have the access token, we redirect back to retry the
  # request with the new access token.

  def auth_endpoint_callback
    Rails.logger.debug "------ Entering auth_endpoint_callback ------"

    @organization = Organization.find(params[:org])

    @organization.authorization_server.request_access_token(request, callback_url)
    redirect_to organization_records_path(@organization)
  end

  #-------------------------------------------------------------------------------
  private
  #-------------------------------------------------------------------------------

  ##
  # Retrieves the resource from the protected resource server.  If authorization
  # fails, we redirect to the authorization server's authorization endpoint.
  #
  # Params:
  #   +uri+::             URI for the resource on the resource server
  #
  # Returns:
  #   +response+::        Response containing resource information, if successful
  
  def get_resource(uri)
    response = @organization.resource_server.get_resource("/test-stub/api/#{uri}.json")
    case response.status
    when UNAUTHORIZED
      unauthorized_request
    when OK
      JSON.parse(response.body)
    else
      raise "Response error: #{response.inspect}"
    end
  end

  #-------------------------------------------------------------------------------

  ##
  # The request to the resource server was unauthorized, so we redirect the
  # request to authorization server to get an authorization code.  
  #
  # If successful, the callback URL we provide will be called by the 
  # authorization server with the authorization code.

  def unauthorized_request
    Rails.logger.debug "------ 'Unauthorized' response from resource server ------"

    authorize_path = @organization.authorization_server.authorize_path(callback_url)
    Rails.logger.debug "------ Redirecting to: #{authorize_path} ------"
    redirect_to authorize_path
  end

  #-------------------------------------------------------------------------------

  ##
  # Generates the callback URL for the authorization server to use when the
  # authorization code request is complete.  
  #
  # We add the organization to the URL so that we can recover the organization in 
  # the callback.
  #
  # Returns:
  #   +String+::          URL for authorization server to callback upon completion

  def callback_url
    auth_endpoint_callback_url(org: @organization.id)
  end

end
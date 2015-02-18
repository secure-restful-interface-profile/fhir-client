##
# = Records Controller
#
# The class retrieves the patient records from the specified organization.  It
# also responds to callbacks from the authorization server.

class RecordsController < ApplicationController

  before_action   :require_signin
  before_action   :find_organization

  #-------------------------------------------------------------------------------

  ##
  # GET /organizations/1/records
  # GET /organizations/1/records.json
  #
  # Retrieves patient records from the resource server.  The patient may be
  # implicit depending on authorization of the requester.  If so, only the records 
  # for that patient are retrieved.
  
  def index
    Rails.logger.debug "======== Enter RecordsController::index ========"

    # Each of these calls to get resources can result in a redirection for 
    # authorization.  Don't continue if we redirect - we'll get called again 
    # later after authorization is complete.

    success = get_resource("patient")

    Rails.logger.debug "  ------ success = #{success} ------"
    Rails.logger.debug "  ------ @patients = #{@patients.inspect} ------"

    if success && (@patients.size == 1)
      Rails.logger.debug "  ------ @patients.size = #{@patients.size} ------"
      # Get the rest of the patient information
      success = get_resource("condition")
      success &&= get_resource("medication")    if success
      success &&= get_resource("encounter")     if success
      success &&= get_resource("observation")   if success

      Rails.logger.debug "  ------ @conditions = #{@conditions.inspect} ------"
      Rails.logger.debug "  ------ @medications = #{@medications.inspect} ------"
      Rails.logger.debug "  ------ @encounters = #{@encounters.inspect} ------"
      Rails.logger.debug "  ------ @observations = #{@observations.inspect} ------"
    end
  end
  
  #-------------------------------------------------------------------------------

  ##
  # GET /organizations/1/records/1
  # GET /organizations/1/records/1.json
  #
  # Retrieves the patient record specified by ID from the resource server.
  
  def show
    Rails.logger.debug "======== Enter RecordsController::show ========"

    # Each of these calls to get resources can result in a redirection for 
    # authorization.  Don't continue if we redirect - we'll get called again 
    # later after authorization is complete.

    query = "?patient=" + params[:id]

    success = get_resource("patient/@" + params[:id])

    success &&= get_resource("condition" + query)     if success
    success &&= get_resource("medication" + query)    if success
    success &&= get_resource("encounter" + query)     if success
    success &&= get_resource("observation" + query)   if success
  end

  #-------------------------------------------------------------------------------
  private
  #-------------------------------------------------------------------------------

  ##
  # Looks up the organization for the requested record and sets the instance
  # variable for the remainder of the request handling.  This is used as a 
  # before filter.

  def find_organization
    @organization = Organization.find(params[:organization_id])
  end

  #-------------------------------------------------------------------------------

  ##
  # Retrieves the resource from the protected resource server.  If authorization
  # fails, we redirect to the authorization server's authorization endpoint.
  #
  # Params:
  #   +uri+::             URI for the resource on the resource server
  #
  # Attributes:
  #   +response+::        Response containing resource information, if successful
  #
  # Returns:
  #   +Boolean+::         true if request handled, false if redirected
  
  def get_resource(resource)
    response = @organization.resource_server.get_resource(resource,
                                                session[:access_token])
    Rails.logger.debug "----- response.status = #{response.status} -----"

    case response.status
    when UNAUTHORIZED
      unauthorized_request
      false
    when FORBIDDEN
      instance_variable_set("@#{resource.pluralize}", nil)
      true
    when OK
      fhir = JSON.parse(response.body)
      Rails.logger.debug "----- FHIR response = #{fhir} -----"
      instance_variable_set("@#{resource.pluralize}", 
                                klass(resource).parse_from_fhir(fhir))
      true
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

    authorize_path = auth_path(@organization.nickname)
    Rails.logger.debug "------ Redirecting to: #{authorize_path} ------"
    redirect_to authorize_path
  end

  #-------------------------------------------------------------------------------

  def klass(model_name)
    Object.const_get(model_name.classify)
  end

end
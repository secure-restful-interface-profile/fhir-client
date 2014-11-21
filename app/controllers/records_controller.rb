##
# = Records Controller
#
# <description>

class RecordsController < ApplicationController

  def index
    Rails.logger.debug "======== Enter RecordsController::index ========"

    @response = get_resource("https://ehr-va.mitre.org/test-stub/api/conditions.json")
  end
  
  #-------------------------------------------------------------------------------

  def auth_endpoint_callback
    Rails.logger.debug "------ Entering auth_endpoint_callback ------"
    # Watch for CSRF attack...
    #if params["state"] == @state
      # Get authorization code which we use to get an access token
      AUTH_SERVER.get_access_token(params["code"])
      redirect_to '/records'
    #else
      # Potential CSRF attack...
    #end
  end

  #-------------------------------------------------------------------------------
  private
  #-------------------------------------------------------------------------------

  def resource_server
    @resource_server ||= Faraday.new(@resource_uri, :ssl => {:verify => false}) do |builder|
      builder.request   :url_encoded    # Encode request parameters as "www-form-urlencoded"
      builder.response  :logger         # Log request and response to STDOUT
      builder.adapter   :net_http       # Perform requests with Net::HTTP
    end
  end

  #-------------------------------------------------------------------------------

  def get_resource(uri)
    response = resource_server.get(uri) do |request|
      access_token = AUTH_SERVER.access_token
      request.headers["Authorization"] = "Bearer #{access_token}" if access_token

      Rails.logger.debug "--------- request.headers = #{request.headers.inspect} ----------"
      Rails.logger.debug "--------- request.body = #{request.body.inspect} ---------"
    end

    Rails.logger.debug "--------- response.headers = #{response.headers.inspect} ----------"
    Rails.logger.debug "--------- response.body = #{response.body} ----------"

    if response.status == 401
      Rails.logger.debug "------ Received 401 from resource server ------"

      authorize_path = AUTH_SERVER.authorize_path(
                                "http://localhost:3000/auth_endpoint_callback")

      Rails.logger.debug "------ Redirecting to: #{authorize_path} ------"
      redirect_to authorize_path
    elsif response.status == 200
      response
    end
  end

  #-------------------------------------------------------------------------------

  # def auth_server
  #   auth_server = Rails.cache.read("https://as-va.mitre.org")
  #   unless auth_server
  #     # Cache authorization server instance for later...
  #     auth_server = AuthorizationServer.new("https://as-va.mitre.org", 
  #                                               PROVIDERS[:asva][:client_id])
  #     Rails.cache.write("https://as-va.mitre.org", auth_server)
  #   end
    
  #   auth_server
  # end

end
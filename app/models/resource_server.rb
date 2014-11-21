class ResourceServer

  ##
  # This method initializes a new instance of the AuthorizationServer class and
  # sets up the necessary configurations for the communicating with the server.
  #
  # Params:
  #   +auth_server_uri+::   Authorization server to use
  #   +rsrc_server_uri+::   URI of protected resource server
  #
  # Attributes set:
  #   +@uri+::              URI of the authorization server
  #   +@connection+::       Connection object to be used for further communication
  #   +@configuration+::    Hash of server capabilities and endpoints

  def initialize(auth_server)
    @auth_server = auth_server
  end

  #-------------------------------------------------------------------------------

  def get_resource(uri)
    retries = 0
    success = false

    while retries <= 1 && !success
      response = resource_server.get(uri) do |request|
        request.body = {
          "access_token"  => @access_token
        }
      end

      if response.status == 401
        retries += 1
        Rails.logger.debug "------ Received 401 from resource server ------"

        @state = "#{Time.now.to_i}/#{SecureRandom.hex(18)}"      

        # Redirect the user to the authorization server 
        authorize_path = @auth_server.configuration["authorization_endpoint"] + "?" +
                            "response_type=code&" +
                            "client_id=#{PROVIDERS[:asva][:client_id]}&" + 
                            "redirect_uri=http://localhost:3000/auth_endpoint_callback&" +
                            "state=#{@state}"

        Rails.logger.debug "------ Redirecting to: #{authorize_path} ------"

        redirect_to authorize_path
      elsif response.status == 200
        success = true
        response_data = JSON.parse(response.body)
        @access_token = response_data[:access_token]
      end
    end

    byebug
    response if success
  end

end
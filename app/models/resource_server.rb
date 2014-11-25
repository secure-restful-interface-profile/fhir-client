##
# = ResourceServer model
#
# This class manages the interface to the Protected Resource Server.

class ResourceServer

  ##
  # Initializes a new instance of the ResuourceServer class and sets up the 
  # necessary configurations for the communicating with the server.
  #
  # Params:
  #   +server_uri+::            URI of protected resource server
  #   +authorization_server+::  Authorization server to use

  def initialize(server_uri, authorization_server)
    @server_uri = server_uri
    @authorization_server = authorization_server
  end

  #-------------------------------------------------------------------------------

  ##
  # Retrieves the resource specified by the URI from the resource server.  If
  # the request is unauthorized, the request is redirected to the authorization
  # server.
  #
  # Params:
  #   +uri+::                   URI of the requested resource
  #   +access_token+::          Access token from authorization server
  #
  # Returns::
  #   +response+::              Response from the server

  def get_resource(uri, access_token)
    response = connection.get(@server_uri + uri) do |request|
      request.headers["Authorization"] = "Bearer #{access_token}" unless access_token.blank?

      Rails.logger.debug "--------- request.headers = #{request.headers.inspect} ----------"
      Rails.logger.debug "--------- request.body = #{request.body.inspect} ---------"
    end

    Rails.logger.debug "--------- response.headers = #{response.headers.inspect} ----------"
    Rails.logger.debug "--------- response.body = #{response.body} ----------"

    response
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

end
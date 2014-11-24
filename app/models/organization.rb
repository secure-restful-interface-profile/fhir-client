##
# = Organization model
#
# This class stores the authorization and protected resource server information 
# for an organization.

class Organization < ActiveRecord::Base

  ##
  # Initializes the interface to the authorization server for the organization.
  #
  # Returns:
  #   +AuthorizationServer+::       Interface to authorization server

  def authorization_server
    @authorization_server ||= AuthorizationServer.new(self.authorization_server_uri,  
                                                        self.client_id)
  end

  #-------------------------------------------------------------------------------

  ##
  # Initializes the interface to the resource server for the organization.
  #
  # Returns:
  #   +ResourceServer+::            Interface to authorization server

  def resource_server
    @resource_server ||= ResourceServer.new(self.resource_server_uri, 
                                                    authorization_server)
  end

end

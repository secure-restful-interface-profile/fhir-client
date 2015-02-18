##
# = Organization model
#
# This class stores the authorization and protected resource server information 
# for an organization.

class Organization < ActiveRecord::Base

  ##
  # Provides a shortened nickname for the organization for OmniAuth.
  #
  # For example, if the URL for the organization is 
  # "https://organization.example.com", the nickname would be "organization".
  #
  # This is configuration-specific and may need to change in different 
  # organization configurations.
  #
  # Returns:
  #   +String+::          Shortened nickname for organization

  def nickname
    self.authorization_server_uri.split('.').first.split('://').last
  end

  #-------------------------------------------------------------------------------

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

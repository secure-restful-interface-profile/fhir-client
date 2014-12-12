##
# = IdentityProvider model
#
# This class stores the information for accessing an identity provider.

class IdentityProvider < ActiveRecord::Base

  ##
  # Provides a shortened nickname for the identity provider for OmniAuth.
  #
  # For example, if the URL for the identity provider is 
  # "https://identity.example.com", the nickname would be "identity".
  #
  # This is configuration-specific and may need to change in different 
  # identity server configurations.
  #
  # Returns:
  #   +String+::          Shortened nickname for identity provider

  def nickname
    host.split('.').first
  end

  #-------------------------------------------------------------------------------

  ##
  # Retrieves the host name of the identity provider URL.  
  #
  # For example, if the URL for the identity provider is 
  # "https://identity.example.com", the host would be "identity.example.com".
  #
  # Returns:
  #   +String+::          Host for the identity provider (e.g. "identity.example.com")

  def host
    URI(self.uri).host
  end

end

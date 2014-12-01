##
# = IdentityProvider model
#
# This class stores the information for accessing an identity provider.

class IdentityProvider < ActiveRecord::Base

  def nickname
    host.split('.').first
  end

  #-------------------------------------------------------------------------------

  def host
    URI(self.uri).host
  end

end

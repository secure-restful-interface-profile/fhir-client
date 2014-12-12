##
# = Application model
#
# This class manages the OAuth attributes for the application.

class Application

	##
	# Retrieves the OpenSSL public key for the application.  
  #
  # The public key is retrieved by the authorization server via the JWKS endpoint 
  # of this application.  The authorization server uses the public key to decrypt
  # requests from this application signed with our private key.

  def self.public_key
    OpenSSL::PKey::RSA.new(File.read(Rails.root.join('config','client.pub')))
  end

  #-------------------------------------------------------------------------------
 
	##
	# Retrieves the OpenSSL private key for the application.  The private key is 
  # used to sign requests to the authorization and resource servers.
	
  def self.private_key
    OpenSSL::PKey::RSA.new(File.read(Rails.root.join('config', 'client.key')))
  end

  #-------------------------------------------------------------------------------

	##
	# Retrieves the client ID for the application, which is used by the identity
  # provider to identify the application.
	
  def self.client_id
    'cd2618f8-a2fd-4770-8d9a-6dc70db9c068'
    #File.read(Rails.root.join('config','client.id'))
  end

end

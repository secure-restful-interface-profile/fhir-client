##
# = Application model
#
# This class manages the OAuth attributes for the application.

class Application

	##
	#

  def self.public_key
    OpenSSL::PKey::RSA.new(File.read(Rails.root.join('config','client.pub')))
  end

  #-------------------------------------------------------------------------------
 
	##
	#
	
  def self.private_key
    OpenSSL::PKey::RSA.new(File.read(Rails.root.join('config', 'client.key')))
  end

  #-------------------------------------------------------------------------------

	##
	#
	
  def self.certificate
    File.read(Rails.root.join('config','server.crt'))
  end

  #-------------------------------------------------------------------------------

	##
	#
	
  def self.client_id
    'cd2618f8-a2fd-4770-8d9a-6dc70db9c068'
    #File.read(Rails.root.join('config','client.id'))
  end

  #-------------------------------------------------------------------------------

	##
	#
	
  def self.resource_server
    File.read(Rails.root.join('config','resource_server'))
   end

  #-------------------------------------------------------------------------------

	##
	#
	
  def self.authorization_server
    File.read(Rails.root.join('config','authorization_server'))
  end

  #-------------------------------------------------------------------------------

	##
	#
	
  def self.test_access_token
    File.read(Rails.root.join('config','test_access_token'))
  end
  
end

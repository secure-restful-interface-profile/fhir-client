require 'omniauth'

module OmniAuth
  module Strategies

    class DistributedTrust

      include OmniAuth::Strategy

      args [ :auth_server_uri ]

      #---------------------------------------------------------------------------

      def setup_phase
        @authorization_server = AuthorizationServer.new(options[:auth_server_uri])
        super
      end

      #---------------------------------------------------------------------------

      ##
      # The request to the resource server was unauthorized, so we redirect the
      # request to authorization server to get an authorization code.  
      #
      # If successful, the callback URL we provide will be called by the 
      # authorization server with the authorization code.
      
      def request_phase
        Rails.logger.debug "====== Entering DistributedTrust::request_phase ======"

        authorize_path = @authorization_server.authorize_path(callback_url)
        Rails.logger.debug "------ Redirecting to: #{authorize_path} ------"
        redirect_to authorize_path
      end

      #---------------------------------------------------------------------------

      ##
      # Called when the authorization server grants us an authorization code.  With
      # the authorization code, we make another call to the authorization server to
      # request an access token.  We need the access token to access resources from
      # the resource server.
      #
      # Once we successfully have the access token, we redirect back to retry the
      # request with the new access token.

      def callback_phase
        Rails.logger.debug "====== Entering DistributedTrust::callback_phase ======"

        session["access_token"] = @authorization_server.
                                        request_access_token(request, callback_url)
        redirect_to organization_records_path(@organization)
      end

      #---------------------------------------------------------------------------
      private
      #---------------------------------------------------------------------------

      ##
      # Generates the callback URL for the authorization server to use when the
      # authorization code request is complete.  
      #
      # We add the organization to the URL so that we can recover the organization 
      # in the callback.
      #
      # Returns:
      #   +String+::          URL for authorization server to callback upon completion

      def callback_url
        auth_endpoint_callback_url(org: @organization.id)
      end

    end

  end
end


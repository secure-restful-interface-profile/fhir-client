require 'omniauth'

module OmniAuth
  module Strategies

    class Heart

      include OmniAuth::Strategy
      include AuthorizationServer

      args [ :request, :auth_server_uri, :callback_url ]

      #---------------------------------------------------------------------------

      ##
      # Establish a connection with the specified authorization server.
      
      def setup_phase
        @authorization_server = AuthorizationServer.new(options.auth_server_uri)
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
        Rails.logger.debug "====== Entering Heart::request_phase ======"

        authorize_path = @authorization_server.authorize_path(options.callback_url)
        Rails.logger.debug "------ Redirecting to: #{authorize_path} ------"
        redirect_to(authorize_path)
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
        Rails.logger.debug "====== Entering Heart::callback_phase ======"

        session["access_token"] = @authorization_server.
                                      request_access_token(request, 
                                                              options.callback_url)

        # Retry the original request
        redirect_to(options.request)
      end

    end

  end
end


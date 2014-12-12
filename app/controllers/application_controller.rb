##
# = Application Controller
#
# This class provides base functionality for all of the other controllers in the
# application, including CSRF protection, authentication and authorization
# support, and general exception handing.

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  
  protect_from_forgery  with: :exception

  #-------------------------------------------------------------------------------

  ##
  # Provides general exception handling.  The user is redirected to the home
  # page with a message about the exception.

  rescue_from StandardError do |exception|
    Rails.logger.error { "#{exception.message} #{exception.backtrace.join("\n")}" }

    redirect_to root_url, :alert => exception.message
  end

  #-------------------------------------------------------------------------------
  private
  #-------------------------------------------------------------------------------

  ##
  # Used as a before action filter to ensure that the user is signed in.  If
  # the user is not signed in, they are redirected to the signin page.

  def require_signin
    redirect_to signin_path unless current_user
  end

  #-------------------------------------------------------------------------------

  ##
  # Used as a before action filter to ensure that the user is an administrator.
  # If the user is not an administrator, they are redirected to the home page.

  def require_admin
    redirect_to(root_url, 
                :alert => "Sorry, you don't have authorization to do that.") unless
                    is_admin?
  end

  #-------------------------------------------------------------------------------

  ##
  # Retrieves the current logged in user for this session.  If the user has not 
  # logged in, NIL is returned.  This method is also a helper method, meaning it 
  # can also be accessed from views.
  
  def current_user
    @current_user ||= session[:email]
  end

  helper_method :current_user

  #-------------------------------------------------------------------------------

  ##
  # Determines whether the current user is an admin.  This method is also a 
  # helper method, meaning it can also be accessed from views.
  #
  # Returns:
  #   +Boolean+::         true if user is an admin, otherwise false

  def is_admin?
    @current_user && @current_user.starts_with?('admin')
  end

  helper_method :is_admin?

end

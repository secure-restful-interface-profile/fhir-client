##
# = Application Controller
#
# <description>

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  
  protect_from_forgery with: :exception

  #-------------------------------------------------------------------------------

  ##
  # General exception handling...

  rescue_from StandardError do |exception|
    Rails.logger.error { "#{exception.message} #{exception.backtrace.join("\n")}" }

    redirect_to root_url, :alert => exception.message
  end

  #-------------------------------------------------------------------------------
  private
  #-------------------------------------------------------------------------------

  ##
  #

  def current_user
  	#@current_user ||= User.find(session[:user_id]) if session[:user_id]
  	#@current_user ||= session[:user_id]
    @current_user ||= session[:email]
  end

  helper_method :current_user

end

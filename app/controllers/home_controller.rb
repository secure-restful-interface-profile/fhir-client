##
# = Home Controller
#
# The class manages the home page for the application.

class HomeController < ApplicationController

  before_action   :require_signin

  #-------------------------------------------------------------------------------

  ##
  # GET /
  #
  # Displays a list of organizations from which the user can get information.

  def index
    @organizations = Organization.all
  end
  
end
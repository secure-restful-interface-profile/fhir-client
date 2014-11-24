##
# = Home Controller
#
# <description>

class HomeController < ApplicationController

  ##
  # GET /
  #
  # Displays a list of organizations from which the user can get information.

  def index
    @organizations = Organization.all
  end
  
end
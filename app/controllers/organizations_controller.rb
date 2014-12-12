##
# = Organizations Controller
#
# The class allows administrators to manage the list of organizations that can
# be accessed by this application.

class OrganizationsController < ApplicationController

  before_action   :require_admin
  before_action   :set_organization, only: [:show, :edit, :update, :destroy]

  #-------------------------------------------------------------------------------

  ##
  # GET /organizations
  # GET /organizations.json
  #
  # Retrieves a list of organizations whose records we can access.

  def index
    @organizations = Organization.all
  end

  #-------------------------------------------------------------------------------

  ##
  # GET /organizations/1
  # GET /organizations/1.json
  #
  # Retrieves the specified organization record from the database (actually done
  # by the before action routine).

  def show
  end

  #-------------------------------------------------------------------------------

  ##
  # GET /organizations/new
  # 
  # Builds a new organization instance in memory and renders HTML form.

  def new
    @organization = Organization.new
  end

  #-------------------------------------------------------------------------------

  # GET /organizations/1/edit
  #
  # Retrieves the specified organization record from the database (actually 
  # done by the before action routine) and renders HTML form.

  def edit
  end

  #-------------------------------------------------------------------------------

  ##
  # POST /organizations
  # POST /organizations.json

  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        format.html { redirect_to @organization, notice: 'Organization was successfully created.' }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  #-------------------------------------------------------------------------------

  ##
  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json

  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: 'Organization was successfully updated.' }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :edit }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  #-------------------------------------------------------------------------------

  ##
  # DELETE /organizations/1
  # DELETE /organizations/1.json

  def destroy
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url, notice: 'Organization was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #-------------------------------------------------------------------------------
  private
  #-------------------------------------------------------------------------------

  ##
  # Use callbacks to share common setup or constraints between actions.

  def set_organization
    @organization = Organization.find(params[:id])
  end

  #-------------------------------------------------------------------------------

  ##
  # Never trust parameters from the scary internet, only allow the white list through.

  def organization_params
    params.require(:organization).permit(:name, :resource_server_uri, :authorization_server_uri, 
                                          :client_id, :registration_client_uri, 
                                          :registration_access_token, :logo)
  end

end

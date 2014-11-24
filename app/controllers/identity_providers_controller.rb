##
# = Identity Providers Controller
#
# <description>

class IdentityProvidersController < ApplicationController

  before_action :set_identity_provider, only: [:show, :edit, :update, :destroy]

  #-------------------------------------------------------------------------------

  ##
  # GET /identity_providers
  # GET /identity_providers.json

  def index
    @identity_providers = IdentityProvider.all
  end

  #-------------------------------------------------------------------------------

  ##
  # GET /identity_providers/1
  # GET /identity_providers/1.json

  def show
  end

  #-------------------------------------------------------------------------------

  ##
  # GET /identity_providers/new

  def new
    @identity_provider = IdentityProvider.new
  end

  #-------------------------------------------------------------------------------

  ##
  # GET /identity_providers/1/edit

  def edit
  end

  #-------------------------------------------------------------------------------

  ##
  # POST /identity_providers
  # POST /identity_providers.json

  def create
    @identity_provider = IdentityProvider.new(identity_provider_params)

    respond_to do |format|
      if @identity_provider.save
        format.html { redirect_to @identity_provider, notice: 'Identity provider was successfully created.' }
        format.json { render :show, status: :created, location: @identity_provider }
      else
        format.html { render :new }
        format.json { render json: @identity_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  #-------------------------------------------------------------------------------

  ##
  # PATCH/PUT /identity_providers/1
  # PATCH/PUT /identity_providers/1.json

  def update
    respond_to do |format|
      if @identity_provider.update(identity_provider_params)
        format.html { redirect_to @identity_provider, notice: 'Identity provider was successfully updated.' }
        format.json { render :show, status: :ok, location: @identity_provider }
      else
        format.html { render :edit }
        format.json { render json: @identity_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  #-------------------------------------------------------------------------------

  ##
  # DELETE /identity_providers/1
  # DELETE /identity_providers/1.json

  def destroy
    @identity_provider.destroy
    respond_to do |format|
      format.html { redirect_to identity_providers_url, notice: 'Identity provider was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #-------------------------------------------------------------------------------
  private
  #-------------------------------------------------------------------------------

  ##
  # Use callbacks to share common setup or constraints between actions.

  def set_identity_provider
    @identity_provider = IdentityProvider.find(params[:id])
  end

  #-------------------------------------------------------------------------------

  ##
  # Never trust parameters from the scary internet, only allow the white list through.

  def identity_provider_params
    params.require(:identity_provider).permit(:name, :uri, :client_id, 
                                :registration_client_uri, :registration_access_token, 
                                :logo)
  end

end

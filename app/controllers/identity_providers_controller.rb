##
# = Identity Providers Controller
#
# The class allows administrators to manage the list of approved identity
# providers that can use be used to access patient records.

class IdentityProvidersController < ApplicationController

  before_action   :set_identity_provider, only: [:show, :edit, :update, :destroy]

  #-------------------------------------------------------------------------------

  ##
  # GET /identity_providers
  # GET /identity_providers.json
  #
  # Retrieves a list of the approved identity providers.

  def index
    @identity_providers = IdentityProvider.all
  end

  #-------------------------------------------------------------------------------

  ##
  # GET /identity_providers/1
  # GET /identity_providers/1.json
  #
  # Retrieves the specified identity provider record from the database (actually 
  # done by the before action routine).

  def show
  end

  #-------------------------------------------------------------------------------

  ##
  # GET /identity_providers/new
  #
  # Builds a new identity provider instance in memory and renders HTML form.

  def new
    @identity_provider = IdentityProvider.new
  end

  #-------------------------------------------------------------------------------

  ##
  # GET /identity_providers/1/edit
  #
  # Retrieves the specified identity provider record from the database (actually 
  # done by the before action routine) and renders HTML form.

  def edit
  end

  #-------------------------------------------------------------------------------

  ##
  # POST /identity_providers
  # POST /identity_providers.json
  #
  # Creates a new approved identity provider in the database.

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
  #
  # Updates the attributes of an existing approved identity provider in the 
  # database.

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
  #
  # Removes an identity provider from the database.

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
  # Finds the specified identity provider in the database and sets the instance
  # variable for use later in the request.

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

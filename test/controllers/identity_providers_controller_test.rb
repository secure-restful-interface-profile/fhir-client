require 'test_helper'

class IdentityProvidersControllerTest < ActionController::TestCase
  setup do
    @identity_provider = identity_providers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:identity_providers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create identity_provider" do
    assert_difference('IdentityProvider.count') do
      post :create, identity_provider: { client_id: @identity_provider.client_id, logo: @identity_provider.logo, name: @identity_provider.name, registration_access_token: @identity_provider.registration_access_token, registration_client_uri: @identity_provider.registration_client_uri, uri: @identity_provider.uri }
    end

    assert_redirected_to identity_provider_path(assigns(:identity_provider))
  end

  test "should show identity_provider" do
    get :show, id: @identity_provider
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @identity_provider
    assert_response :success
  end

  test "should update identity_provider" do
    patch :update, id: @identity_provider, identity_provider: { client_id: @identity_provider.client_id, logo: @identity_provider.logo, name: @identity_provider.name, registration_access_token: @identity_provider.registration_access_token, registration_client_uri: @identity_provider.registration_client_uri, uri: @identity_provider.uri }
    assert_redirected_to identity_provider_path(assigns(:identity_provider))
  end

  test "should destroy identity_provider" do
    assert_difference('IdentityProvider.count', -1) do
      delete :destroy, id: @identity_provider
    end

    assert_redirected_to identity_providers_path
  end
end

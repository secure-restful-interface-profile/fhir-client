require 'test_helper'

class HealthcareSystemsControllerTest < ActionController::TestCase
  setup do
    @healthcare_system = healthcare_systems(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:healthcare_systems)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create healthcare_system" do
    assert_difference('HealthcareSystem.count') do
      post :create, healthcare_system: { authorization_server: @healthcare_system.authorization_server, client_id: @healthcare_system.client_id, logo: @healthcare_system.logo, name: @healthcare_system.name, registration_access_token: @healthcare_system.registration_access_token, registration_client_uri: @healthcare_system.registration_client_uri, resource_server: @healthcare_system.resource_server }
    end

    assert_redirected_to healthcare_system_path(assigns(:healthcare_system))
  end

  test "should show healthcare_system" do
    get :show, id: @healthcare_system
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @healthcare_system
    assert_response :success
  end

  test "should update healthcare_system" do
    patch :update, id: @healthcare_system, healthcare_system: { authorization_server: @healthcare_system.authorization_server, client_id: @healthcare_system.client_id, logo: @healthcare_system.logo, name: @healthcare_system.name, registration_access_token: @healthcare_system.registration_access_token, registration_client_uri: @healthcare_system.registration_client_uri, resource_server: @healthcare_system.resource_server }
    assert_redirected_to healthcare_system_path(assigns(:healthcare_system))
  end

  test "should destroy healthcare_system" do
    assert_difference('HealthcareSystem.count', -1) do
      delete :destroy, id: @healthcare_system
    end

    assert_redirected_to healthcare_systems_path
  end
end

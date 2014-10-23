require 'test_helper'

class BaselineCharacteristicsControllerTest < ActionController::TestCase
  setup do
    @baseline_characteristic = baseline_characteristics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:baseline_characteristics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create baseline_characteristic" do
    assert_difference('BaselineCharacteristic.count') do
      post :create, :baseline_characteristic => @baseline_characteristic.attributes
    end

    assert_redirected_to baseline_characteristic_path(assigns(:baseline_characteristic))
  end

  test "should show baseline_characteristic" do
    get :show, :id => @baseline_characteristic.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @baseline_characteristic.to_param
    assert_response :success
  end

  test "should update baseline_characteristic" do
    put :update, :id => @baseline_characteristic.to_param, :baseline_characteristic => @baseline_characteristic.attributes
    assert_redirected_to baseline_characteristic_path(assigns(:baseline_characteristic))
  end

  test "should destroy baseline_characteristic" do
    assert_difference('BaselineCharacteristic.count', -1) do
      delete :destroy, :id => @baseline_characteristic.to_param
    end

    assert_redirected_to baseline_characteristics_path
  end
end

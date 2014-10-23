require 'test_helper'

class DesignDetailsControllerTest < ActionController::TestCase
  setup do
    @design_detail = design_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:design_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create design_detail" do
    assert_difference('DesignDetail.count') do
      post :create, :design_detail => @design_detail.attributes
    end

    assert_redirected_to design_detail_path(assigns(:design_detail))
  end

  test "should show design_detail" do
    get :show, :id => @design_detail.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @design_detail.to_param
    assert_response :success
  end

  test "should update design_detail" do
    put :update, :id => @design_detail.to_param, :design_detail => @design_detail.attributes
    assert_redirected_to design_detail_path(assigns(:design_detail))
  end

  test "should destroy design_detail" do
    assert_difference('DesignDetail.count', -1) do
      delete :destroy, :id => @design_detail.to_param
    end

    assert_redirected_to design_details_path
  end
end

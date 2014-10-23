require 'test_helper'

class QualityRatingTemplateFieldsControllerTest < ActionController::TestCase
  setup do
    @quality_rating_template_field = quality_rating_template_fields(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quality_rating_template_fields)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quality_rating_template_field" do
    assert_difference('QualityRatingTemplateField.count') do
      post :create, :quality_rating_template_field => @quality_rating_template_field.attributes
    end

    assert_redirected_to quality_rating_template_field_path(assigns(:quality_rating_template_field))
  end

  test "should show quality_rating_template_field" do
    get :show, :id => @quality_rating_template_field.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @quality_rating_template_field.to_param
    assert_response :success
  end

  test "should update quality_rating_template_field" do
    put :update, :id => @quality_rating_template_field.to_param, :quality_rating_template_field => @quality_rating_template_field.attributes
    assert_redirected_to quality_rating_template_field_path(assigns(:quality_rating_template_field))
  end

  test "should destroy quality_rating_template_field" do
    assert_difference('QualityRatingTemplateField.count', -1) do
      delete :destroy, :id => @quality_rating_template_field.to_param
    end

    assert_redirected_to quality_rating_template_fields_path
  end
end

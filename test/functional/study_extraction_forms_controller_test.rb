require 'test_helper'

class StudyExtractionFormsControllerTest < ActionController::TestCase
  setup do
    @study_extraction_form = study_extraction_forms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:study_extraction_forms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create study_extraction_form" do
    assert_difference('StudyExtractionForm.count') do
      post :create, :study_extraction_form => @study_extraction_form.attributes
    end

    assert_redirected_to study_extraction_form_path(assigns(:study_extraction_form))
  end

  test "should show study_extraction_form" do
    get :show, :id => @study_extraction_form.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @study_extraction_form.to_param
    assert_response :success
  end

  test "should update study_extraction_form" do
    put :update, :id => @study_extraction_form.to_param, :study_extraction_form => @study_extraction_form.attributes
    assert_redirected_to study_extraction_form_path(assigns(:study_extraction_form))
  end

  test "should destroy study_extraction_form" do
    assert_difference('StudyExtractionForm.count', -1) do
      delete :destroy, :id => @study_extraction_form.to_param
    end

    assert_redirected_to study_extraction_forms_path
  end
end

require 'test_helper'

class Admin::LogosControllerTest < ActionController::TestCase
  setup do
    @admin_logo = admin_logos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_logos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_logo" do
    assert_difference('Admin::Logo.count') do
      post :create, admin_logo: {  }
    end

    assert_redirected_to admin_logo_path(assigns(:admin_logo))
  end

  test "should show admin_logo" do
    get :show, id: @admin_logo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_logo
    assert_response :success
  end

  test "should update admin_logo" do
    put :update, id: @admin_logo, admin_logo: {  }
    assert_redirected_to admin_logo_path(assigns(:admin_logo))
  end

  test "should destroy admin_logo" do
    assert_difference('Admin::Logo.count', -1) do
      delete :destroy, id: @admin_logo
    end

    assert_redirected_to admin_logos_path
  end
end

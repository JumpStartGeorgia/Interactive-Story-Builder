require 'test_helper'

class ThemesControllerTest < ActionController::TestCase
  setup do
    @theme = themes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:themes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create theme" do
    assert_difference('Theme.count') do
      post :create, theme: { description: @theme.description, edition: @theme.edition, is_published: @theme.is_published, name: @theme.name, permalink: @theme.permalink, published_at: @theme.published_at, show_home_page: @theme.show_home_page }
    end

    assert_redirected_to theme_path(assigns(:theme))
  end

  test "should show theme" do
    get :show, id: @theme
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @theme
    assert_response :success
  end

  test "should update theme" do
    put :update, id: @theme, theme: { description: @theme.description, edition: @theme.edition, is_published: @theme.is_published, name: @theme.name, permalink: @theme.permalink, published_at: @theme.published_at, show_home_page: @theme.show_home_page }
    assert_redirected_to theme_path(assigns(:theme))
  end

  test "should destroy theme" do
    assert_difference('Theme.count', -1) do
      delete :destroy, id: @theme
    end

    assert_redirected_to themes_path
  end
end

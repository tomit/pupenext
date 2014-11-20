require 'test_helper'

class Administration::SumLevelsControllerTest < ActionController::TestCase
  def setup
    cookies[:pupesoft_session] = users(:joe).session
    @sum_level = sum_levels(:external)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    cookies[:pupesoft_session] = users(:bob).session
    get :new
    assert_response :success
  end

  test "should show sum level" do
    request = { id: @sum_level.id }
    get :show, request
    assert_response :success
  end

  test "should create" do
    cookies[:pupesoft_session] = users(:bob).session
    assert_difference('SumLevel.count', 1) do
      request = {
        tyyppi: 'U',
        summattava_taso: '',
        taso: '2221',
        nimi: 'TILIKAUDEN TULOS2221',
        oletusarvo: '',
        jakaja: '',
        kumulatiivinen: '',
        kayttotarkoitus: '',
        kerroin: '',
      }
      post :create, sum_level: request
    end

    assert_redirected_to sum_levels_path
  end

  test "should not create" do
    assert_no_difference('SumLevel.count') do
      #With non-valid request
      request = {
        tyyppi: 'U',
        summattava_taso: '',
        taso: '',
        nimi: 'TILIKAUDEN TULOS2221',
        oletusarvo: '',
        jakaja: '',
        kumulatiivinen: '',
        kayttotarkoitus: '',
        kerroin: '',
      }
      post :create, sum_level: request
    end

    assert_redirected_to sum_levels_path
  end

  test "should get edit" do
    cookies[:pupesoft_session] = users(:bob).session
    request = { id: @sum_level.id }
    get :edit, request
    assert_response :success
  end

  test "should update" do
    cookies[:pupesoft_session] = users(:bob).session
    patch :update, id: @sum_level.id, sum_level: { nimi: 'Uusi nimi' }
    assert_equal "Taso päivitettiin onnistuneesti", flash[:notice]
    assert_redirected_to sum_levels_path
  end

  test "should not update with invalid data" do
    cookies[:pupesoft_session] = users(:bob).session
    patch :update, id: @sum_level.id, sum_level: { taso: '' }
    assert_template :edit
  end

  test "should destroy" do
    cookies[:pupesoft_session] = users(:bob).session
    assert_difference('SumLevel.count', -1) do
      delete :destroy, id: @sum_level.id
    end

    assert_equal "Taso poistettiin onnistuneesti", flash[:notice]
    assert_redirected_to sum_levels_path
  end
end

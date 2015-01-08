require 'test_helper'
class Accounting::FixedAssets::CommoditiesControllerTest < ActionController::TestCase

  def setup
    cookies[:pupesoft_session] = users(:joe).session

    @commodity = accounting_fixed_assets_commodities(:one_commodity_row)

    @account = accounting_accounts(:one_account_row)
  end

  test 'should get all commodities' do
    get :index
    assert_response :success

    assert_template "index", "Template should be index"
  end

  test 'should show commodity' do
    request = {id: @commodity.id}

    get :show, request
    assert_response :success

    assert_template "edit", "Template should be edit"
  end

  test 'should show new commodity form' do
    get :new
    assert_response :success

    assert_template 'new', 'Template should be new'
  end

  # test 'should update commodity and create bookkeeping rows with type T and P' do
  #   # Creates 60 external bookkeeping reductions
  #   assert_difference('Accounting::FixedAssets::Row.count', 60) do
  #     # Creates 35 internal bookkeeping reductions
  #     assert_difference('Accounting::Row.count', 35) do
  #       patch :update, id: @commodity.id, accounting_fixed_assets_commodity: {
  #         nimitys: 'Skoda 2.0 Turbocharged',
  #         selite: 'Car for CEO',
  #         summa: 10000,
  #         tilino: @account.tilino,
  #         sumu_poistotyyppi: 'T',
  #         sumu_poistoera: 35,
  #         evl_poistotyyppi: 'P',
  #         evl_poistoera: 20,
  #         kayttoonottopvm: Time.now,
  #         hankintapvm: Time.now,
  #         tila: 'A'
  #       }
  #     end
  #   end

  #   assert_redirected_to accounting_fixed_assets_commodities_path
  #   assert_equal "Hyödyke päivitettiin onnistuneesti.", flash[:notice]
  # end

  # test 'should update commodity and create bookkeeping rows type D and B' do
  #   # Creates 38 external bookkeeping reductions
  #   assert_difference('Accounting::FixedAssets::Row.count', 38) do
  #     # Creates 12 internal bookkeeping reductions
  #     assert_difference('Accounting::Row.count', 12) do
  #       patch :update, id: @commodity.id, accounting_fixed_assets_commodity: {
  #         nimitys: 'Chair50000',
  #         selite: 'Chair for CEO',
  #         summa: 10000.0,
  #         tilino: @account.tilino,
  #         sumu_poistotyyppi: 'D',
  #         sumu_poistoera: 12,
  #         evl_poistotyyppi: 'B',
  #         evl_poistoera: 35,
  #         kayttoonottopvm: Time.now,
  #         hankintapvm: Time.now,
  #         tila: 'A'
  #       }
  #     end
  #   end

  #   assert_redirected_to accounting_fixed_assets_commodities_path
  #   assert_equal "Hyödyke päivitettiin onnistuneesti.", flash[:notice]
  # end


  test 'should update commodity and create bookkeeping rows type D and B' do
    # Creates external bookkeeping reductions only for current fiscal year
    assert_difference('Accounting::FixedAssets::Row.count', 11) do
      # Creates internal bookkeeping reductions only for current fiscal year
      assert_difference('Accounting::Row.count', 11) do
        patch :update, id: @commodity.id, accounting_fixed_assets_commodity: {
          nimitys: 'Chair50000',
          selite: 'Chair for CEO',
          summa: 10000.0,
          tilino: @account.tilino,
          sumu_poistotyyppi: 'D',
          sumu_poistoera: 12,
          evl_poistotyyppi: 'B',
          evl_poistoera: 45,
          kayttoonottopvm: Time.now,
          hankintapvm: Time.now,
          tila: 'A'
        }
      end
    end

    assert_redirected_to accounting_fixed_assets_commodities_path
    assert_equal "Hyödyke päivitettiin onnistuneesti.", flash[:notice]
  end

  test 'should not create new commodity due to permissions' do
    # User bob does not have permission to create
    cookies[:pupesoft_session] = users(:bob).session

    assert_no_difference('Accounting::FixedAssets::Commodity.count') do
      post :create, accounting_fixed_assets_commodity: {
        nimitys: 'Kerrostalo', selite: 'Nooh halvalla sai', summa: 300
      }
    end

    assert_redirected_to accounting_fixed_assets_commodities_path
    assert_equal "Sinulla ei ole päivitysoikeuksia.", flash[:notice]
  end

  test 'should not create new commodity due to params missing' do
    assert_no_difference('Accounting::FixedAssets::Commodity.count') do
      post :create, accounting_fixed_assets_commodity: {
        nimitys: '', selite: '', summa: 300, tila: 'A'
      }
    end

    assert_template 'new', 'Template should be new'
  end

  test 'should update commodity' do
    patch :update, id: @commodity.id, accounting_fixed_assets_commodity: {
      nimitys: 'Kissa'
    }

    assert_redirected_to accounting_fixed_assets_commodities_path
    assert_equal "Hyödyke päivitettiin onnistuneesti.", flash[:notice]
  end

  test 'should not update commodity due to rights' do
    cookies[:pupesoft_session] = users(:bob).session

    patch :update, id: @commodity.id, accounting_fixed_assets_commodity: {nimi: ''}

    assert_redirected_to accounting_fixed_assets_commodities_path
    assert_equal "Sinulla ei ole päivitysoikeuksia.", flash[:notice]
  end

  test 'should not update commodity due to required params missing' do
    patch :update, id: @commodity.id, accounting_fixed_assets_commodity: {nimitys: ''}

    assert_template 'edit', 'Template should be edit'
  end

  test 'should link commodity cost row' do
    unlinked_row = accounting_rows(:three_accounting_row)
    assert_difference('Accounting::FixedAssets::CommodityCostRow.count') do
      patch :edit, id: @commodity.id, selected_accounting_row: unlinked_row.id
    end
  end

  test 'should search for specific commodity' do
    request = {nimitys: 'Mekkonen'}

    get :index, request
    assert_response :success

    assert_template "index", "Template should be index"
  end

  test 'should search for specific voucher' do
    request = {id: @commodity.id, nimi: 'Acme Corporation Voucher'}

    get 'select_voucher', request
    assert_response :success

    assert_template 'select_voucher', 'Template should be select_voucher'
  end

  test 'should search for specific purchase order' do
    request = {id: @commodity.id, nimi: 'Acme Corporation PO'}

    get 'select_purchase_order', request
    assert_response :success

    assert_template 'select_purchase_order', 'Template should be select_purchase_order'
  end

end

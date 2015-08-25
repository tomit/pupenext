require 'test_helper'

class DeliveryMethodHelperTest < ActionView::TestCase
  test "returns translated pickup options valid for collection" do
    assert pickup_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.pickup_options.shipment', :fi
    assert_equal text, pickup_options.first.first
    assert_equal 'shipment', pickup_options.first.second
  end

  test "returns translated saturday delivery options valid for collection" do
    assert saturday_delivery_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.saturday_delivery_options.saturday_delivery', :fi
    assert_equal text, saturday_delivery_options.second.first
    assert_equal 'saturday_delivery', saturday_delivery_options.second.second
  end

  test "returns translated transport unit options valid for collection" do
    assert transport_unit_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.transport_unit_options.transport_unit', :fi
    assert_equal text, transport_unit_options.second.first
    assert_equal 'transport_unit', transport_unit_options.second.second
  end

  test "returns translated print method options valid for collection" do
    assert print_method_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.print_method_options.batch', :fi
    assert_equal text, print_method_options.first.first
    assert_equal 'batch', print_method_options.first.second
  end

  test "returns translated freight contract options valid for collection" do
    assert freight_contract_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.freight_contract_options.sender_freight_contract', :fi
    assert_equal text, freight_contract_options.first.first
    assert_equal 'sender_freight_contract', freight_contract_options.first.second
  end

  test "returns translated logy waybill number options valid for collection" do
    assert logy_waybill_number_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.logy_waybill_number_options.use_logy_waybill_numbers', :fi
    assert_equal text, logy_waybill_number_options.second.first
    assert_equal 'use_logy_waybill_numbers', logy_waybill_number_options.second.second
  end

  test "returns translated extranet options valid for collection" do
    assert extranet_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.extranet_options.only_in_sales', :fi
    assert_equal text, extranet_options.first.first
    assert_equal 'only_in_sales', extranet_options.first.second
  end

  test "returns translated container options valid for collection" do
    assert container_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.container_options.includes_container', :fi
    assert_equal text, container_options.first.first
    assert_equal 'includes_container', container_options.first.second
  end

  test "returns translated cash on delivery prohibition options valid for collection" do
    assert cash_on_delivery_prohibition_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.cash_on_delivery_prohibition_options.cash_on_delivery_permitted', :fi
    assert_equal text, cash_on_delivery_prohibition_options.first.first
    assert_equal 'cash_on_delivery_permitted', cash_on_delivery_prohibition_options.first.second
  end

  test "returns translated special packaging prohibition options valid for collection" do
    assert special_packaging_prohibition_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.special_packaging_prohibition_options.special_packaging_permitted', :fi
    assert_equal text, special_packaging_prohibition_options.first.first
    assert_equal 'special_packaging_permitted', special_packaging_prohibition_options.first.second
  end

  test "returns translated packing line prohibition options valid for collection" do
    assert packing_line_prohibition_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.packing_line_prohibition_options.reserve_packing_line', :fi
    assert_equal text, packing_line_prohibition_options.first.first
    assert_equal 'reserve_packing_line', packing_line_prohibition_options.first.second
  end

  test "returns translated waybill specification options valid for collection" do
    assert waybill_specification_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.waybill_specification_options.print_waybill_specification', :fi
    assert_equal text, waybill_specification_options.second.first
    assert_equal 'print_waybill_specification', waybill_specification_options.second.second
  end

  test "returns translated new packaging information options for collection" do
    assert new_packaging_information_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.new_packaging_information_options.package_info_entry_denied', :fi
    assert_equal text, new_packaging_information_options.first.first
    assert_equal 'package_info_entry_denied', new_packaging_information_options.first.second
  end

  test "returns translated transportation insurance type options for collection" do
    assert transportation_insurance_type_options.is_a? Array

    text = I18n.t 'administration.delivery_methods.transportation_insurance_type_options.currency_based_insurance', :fi
    assert_equal text, transportation_insurance_type_options.third.first
    assert_equal 'currency_based_insurance', transportation_insurance_type_options.third.second
  end

  test "should get waybill options" do
    assert_kind_of Array, waybill_options
    assert_equal 'rahtikirja.inc', waybill_options.first.second
  end

  test "should get mode of transport options" do
    assert_kind_of Array, mode_of_transport_options
    assert_equal '1 - Merikuljetus (ml. auto- ja junalauttakuljetus)', mode_of_transport_options.first.first
  end

  test "should get label options" do
    Current.company.parameter.kerayserat = ''

    assert_kind_of Array, label_options
    assert_equal 'Tiivistetty', label_options.third.first
    refute label_options.any? { |_,key| key == 'simple_label' }

    Current.company.parameter.kerayserat = 'K'

    assert_kind_of Array, label_options
    assert label_options.any? { |_,key| key == 'simple_label' }
  end

  test "should get nature of transaction options" do
    assert_kind_of Array, nature_of_transaction_options
    assert_equal '11 - Suora osto/myynti', nature_of_transaction_options.first.first
  end

  test "should get customs options" do
    assert_kind_of Array, customs_options
    assert_equal 'FI001000', customs_options.first.second
  end

  test "should get sorting point options" do
    assert_kind_of Array, sorting_point_options
    assert_equal 'FIVAT', sorting_point_options.first.second
  end

  test "should get adr prohibition options" do
    assert_kind_of Array, adr_prohibition_options
    assert_operator 2, '<', adr_prohibition_options.count
    assert_equal 'Kaukokiito', adr_prohibition_options.third.second

    text = I18n.t 'administration.delivery_methods.adr_prohibition_options.permit_adr', :fi
    assert_equal text, adr_prohibition_options.first.first
  end
end

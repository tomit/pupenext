require 'test_helper'

class Import::CustomerSalesTest < ActiveSupport::TestCase
  include SpreadsheetsHelper

  fixtures %w(
    customers
    keyword/customer_categories
    products
    sales_order/detail_rows
    sales_order/details
  )

  setup do
    @user = users(:joe).id
    @company = users(:joe).company.id

    @helmet = products :helmet
    @helmet.update! tuoteno: '12345'

    @hammer = products :hammer
    @hammer.update! tuoteno: '67890'

    @default_detail_product = products(:default_detail_product).tuoteno
    @default_detail_customer = customers(:default_detail_customer).asiakasnro

    @customer = customers :stubborn_customer
    @lissu    = customers :lissu

    @customer_category = keyword_customer_categories(:customer_category_1)
  end

  test 'imports sales and returns response' do
    filename = create_xlsx([
      ['Asiakas/Tuote',                                           'Kpl', 'Myynti EUR' ],
      ['Yhteensä',                                                '',    123000       ],
      ["#{@customer.asiakasnro} #{@customer.nimi}",               '',    23000        ],
      ["#{@helmet.tuoteno} #{@helmet.osasto} #{@helmet.nimitys}", 10,    23000        ],
      ["#{@hammer.tuoteno} #{@hammer.osasto} #{@hammer.nimitys}", 23,    100000       ],
      ["#{@lissu.asiakasnro} #{@lissu.nimi}",                     '',    100000       ],
      ["#{@helmet.tuoteno} #{@helmet.osasto} #{@helmet.nimitys}", 0,     23000        ],
      ["#{@hammer.tuoteno} #{@hammer.osasto} #{@hammer.nimitys}", 23,    100000       ],
      ['Yhteensä',                                                '',    123000       ],
    ])

    params = {
      company_id: @company,
      user_id: @user,
      filename: filename,
      month: 1,
      year: 2016,
      product: nil,
      customer_number: nil,
      customer_category: @customer_category.selite,
    }

    sales = Import::CustomerSales.new params

    assert_difference 'SalesOrder::Detail.count', 2 do
      assert_difference 'SalesOrder::DetailRow.count', 4 do
        response = sales.import
        assert_equal Import::Response, response.class
        assert_equal [], response.rows.map(&:errors).flatten.compact
      end
    end
  end

  test 'adding with invalid data should fallback to defaults' do
    filename = create_xlsx([
      ['Asiakas/Tuote',                            'Kpl', 'Myynti EUR' ],
      ['Yhteensä',                                 '',    123000       ],
      ["666 #{@customer.nimi}",                    '',    23000        ],
      ["foobar",                                   '',    23000        ],
      ["999 #{@helmet.osasto} #{@helmet.nimitys}", 10,    23000        ],
      ["foobar",                                   10,    23000        ],
      ['Yhteensä',                                 '',    123000       ],
    ])

    params = {
      company_id: @company,
      user_id: @user,
      filename: filename,
      month: 1,
      year: 2016,
      product: @default_detail_product,
      customer_number: @default_detail_customer,
      customer_category: @customer_category.selite,
    }

    sales = Import::CustomerSales.new params

    assert_difference 'SalesOrder::Detail.count', 2 do
      assert_difference 'SalesOrder::DetailRow.count', 2 do
        response = sales.import
        assert_equal Import::Response, response.class
        expected = [
          'Kirjattu ERIKOISMYYNTITUOTE tuotteelle. ',
          'Kirjattu 123456999 asiakkaalle. ',
          'Kirjattu ERIKOISMYYNTITUOTE tuotteelle. ',
          'Kirjattu 123456999 asiakkaalle. ',
        ]
        assert_equal expected, response.rows.map(&:errors).flatten.compact
      end
    end
  end

  test 'adding with invalid data should fail' do
    filename = create_xlsx([
      ['Asiakas/Tuote',                            'Kpl', 'Myynti EUR' ],
      ['Yhteensä',                                 '',    123000       ],
      ["666 #{@customer.nimi}",                    '',    23000        ],
      ["foobar",                                   '',    23000        ],
      ["999 #{@helmet.osasto} #{@helmet.nimitys}", 10,    23000        ],
      ["foobar",                                   10,    23000        ],
      ['Yhteensä',                                 '',    123000       ],
    ])

    params = {
      company_id: @company,
      user_id: @user,
      filename: filename,
      month: 1,
      year: 2016,
      product: nil,
      customer_number: nil,
      customer_category: @customer_category.selite,
    }

    sales = Import::CustomerSales.new params

    assert_no_difference 'SalesOrder::Detail.count' do
      assert_no_difference 'SalesOrder::DetailRow.count' do
        response = sales.import
        assert_empty response.rows
      end
    end
  end

  test 'should skip invalid customer' do

    # Try adding with incorrect customer
    filename = create_xlsx([
      ['Asiakas/Tuote',                                           'Kpl', 'Myynti EUR' ],
      ['Yhteensä',                                                '',    123000       ],
      ["#{@customer.asiakasnro} #{@customer.nimi}",               '',    23000        ],
      ["#{@helmet.tuoteno} #{@helmet.osasto} #{@helmet.nimitys}", 10,    23000        ],
      ["#{@hammer.tuoteno} #{@hammer.osasto} #{@hammer.nimitys}", 10,    23000        ],
      ["999 #{@customer.nimi}",                                   '',    23000        ],
      ["#{@helmet.tuoteno} #{@helmet.osasto} #{@helmet.nimitys}", 10,    23000        ],
      ["#{@lissu.asiakasnro} #{@lissu.nimi}",                     '',    23000        ],
      ["#{@helmet.tuoteno} #{@helmet.osasto} #{@helmet.nimitys}", 10,    23000        ],
      ["#{@hammer.tuoteno} #{@hammer.osasto} #{@hammer.nimitys}", 10,    23000        ],
      ['Yhteensä',                                                '',    123000       ],
    ])

    params = {
      company_id: @company,
      user_id: @user,
      filename: filename,
      month: 1,
      year: 2016,
      product: nil,
      customer_number: nil,
      customer_category: @customer_category.selite,
    }

    # We get only one error
    sales = Import::CustomerSales.new params

    assert_difference 'SalesOrder::Detail.count', 2 do
      assert_difference 'SalesOrder::DetailRow.count', 4 do
        result = sales.import
        assert_empty result.rows
      end
    end
  end

  test 'required fields' do
    # Try adding with every incorrect field
    filename = create_xlsx([
      ['wrong',                                                   'column', 'name' ],
      ['Yhteensä',                                                '',       123000 ],
      ["#{@customer.asiakasnro} #{@customer.nimi}",               '',       23000  ],
      ["#{@helmet.tuoteno} #{@helmet.osasto} #{@helmet.nimitys}", 10,       23000  ],
    ])

    params = {
      company_id: @company,
      user_id: @user,
      filename: filename,
      month: 1,
      year: 2016,
      product: nil,
      customer_number: nil,
      customer_category: @customer_category.selite,
    }

    sales = Import::CustomerSales.new params

    assert_no_difference 'SalesOrder::Detail.count' do
      assert_no_difference 'SalesOrder::DetailRow.count' do
        response = sales.import
        assert_equal 0, response.rows.map(&:errors).flatten.count
        assert_equal 0, response.rows.map(&:errors).flatten.uniq.count
      end
    end

    # Try adding with partially incorrect fields
    filename = create_xlsx([
      ['wrong',                                                   'column', 'myynti eur'],
      ['Yhteensä',                                                '',       123000      ],
      ["#{@customer.asiakasnro} #{@customer.nimi}",               '',       23000       ],
      ["#{@helmet.tuoteno} #{@helmet.osasto} #{@helmet.nimitys}", 10,       23000       ],
    ])

    params = {
      company_id: @company,
      user_id: @user,
      filename: filename,
      month: 1,
      year: 2016,
      product: nil,
      customer_number: nil,
      customer_category: @customer_category.selite,
    }

    sales = Import::CustomerSales.new params

    assert_no_difference 'SalesOrder::Detail.count' do
      assert_no_difference 'SalesOrder::DetailRow.count' do
        response = sales.import
        assert_equal 0, response.rows.map(&:errors).flatten.count
        assert_equal 0, response.rows.map(&:errors).flatten.uniq.count
      end
    end
  end

  test 'errors are correct' do
    # Let's store one correct product and customer
    filename = create_xlsx([
      ['Asiakas/Tuote',                                           'Kpl', 'Myynti EUR' ],
      ['Yhteensä',                                                '',    123000       ],
      ["#{@customer.asiakasnro} #{@customer.nimi}",               '',    23000        ],
      ["#{@helmet.tuoteno} #{@helmet.osasto} #{@helmet.nimitys}", 10,    23000        ],
      ['Yhteensä',                                                '',    123000       ],
    ])

    params = {
      company_id: @company,
      user_id: @user,
      filename: filename,
      month: 1,
      year: 2016,
      product: nil,
      customer_number: nil,
      customer_category: @customer_category.selite,
    }

    sales = Import::CustomerSales.new params

    assert_difference 'SalesOrder::Detail.count', 1 do
      assert_difference 'SalesOrder::DetailRow.count', 1 do
        result = sales.import
        assert_empty result.rows
      end
    end

    # Try adding without month
    params = {
      company_id: @company,
      user_id: @user,
      filename: filename,
      year: 2016,
      product: nil,
      customer_number: nil,
    }

    assert_raises(ArgumentError) { Import::CustomerSales.new params }

    # Try adding with incorrect product
    filename = create_xlsx([
      ['Asiakas/Tuote',                             'Kpl', 'Myynti EUR' ],
      ['Yhteensä',                                  '',    123000       ],
      ["#{@customer.asiakasnro} #{@customer.nimi}", '',    23000        ],
      ["666 #{@helmet.osasto} #{@helmet.nimitys}",  10,    23000        ],
      ['Yhteensä',                                  '',    123000       ],
    ])

    params = {
      company_id: @company,
      user_id: @user,
      filename: filename,
      month: 1,
      year: 2016,
      product: nil,
      customer_number: nil,
      customer_category: @customer_category.selite,
    }

    # We get only one error
    sales = Import::CustomerSales.new params

    assert_difference 'SalesOrder::Detail.count', 1 do
      assert_no_difference 'SalesOrder::DetailRow.count' do
        result = sales.import
        assert_empty result.rows
      end
    end

    # Try adding with incorrect customer
    filename = create_xlsx([
      ['Asiakas/Tuote',                                           'Kpl', 'Myynti EUR' ],
      ['Yhteensä',                                                '',    123000       ],
      ["999 #{@customer.nimi}",                                   '',    23000        ],
      ["#{@helmet.tuoteno} #{@helmet.osasto} #{@helmet.nimitys}", 10,    23000        ],
      ['Yhteensä',                                                '',    123000       ],
    ])

    params = {
      company_id: @company,
      user_id: @user,
      filename: filename,
      month: 1,
      year: 2016,
      product: nil,
      customer_number: nil,
      customer_category: @customer_category.selite,
    }

    # We get only one error
    sales = Import::CustomerSales.new params

    assert_no_difference 'SalesOrder::Detail.count' do
      assert_no_difference 'SalesOrder::DetailRow.count' do
        result = sales.import
        assert_empty result.rows
      end
    end
  end
end

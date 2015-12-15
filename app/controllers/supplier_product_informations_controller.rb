class SupplierProductInformationsController < ApplicationController
  include ColumnSort

  def index
    session[:supplier] = params[:supplier] if params[:supplier].present?

    if session[:supplier].present? && search_params.present?
      @supplier                      = Supplier.find(session[:supplier])
      @supplier_product_informations = @supplier.supplier_product_informations.search_like(search_params)
    else
      @supplier_product_informations = SupplierProductInformation.none
    end
  end

  def transfer
    to_transfer = supplier_product_informations_params.select { |_k, v| v[:transfer] == '1' }

    @supplier_product_informations = SupplierProductInformation.find(to_transfer.keys)

    supplier = Supplier.find(session[:supplier])

    duplicates = []

    @supplier_product_informations.each do |s|
      duplicate_products = Product.where('tuoteno = ? OR eankoodi = ?',
                                         s.manufacturer_part_number,
                                         s.manufacturer_ean)
      if duplicate_products.present?
        duplicates << s
        next
      end

      extra_attributes = to_transfer[s.id.to_s]

      s.update(p_price_update: extra_attributes[:toimittajan_ostohinta],
               p_qty_update: extra_attributes[:toimittajan_saldo])

      product_params = {
        alv:         24,
        eankoodi:    s.manufacturer_ean,
        nimitys:     s.product_name,
        tuoteno:     s.manufacturer_part_number
      }

      product_params[:brand]       = Product::Brand.find(extra_attributes[:tuotemerkki]) if extra_attributes[:tuotemerkki]
      product_params[:category]    = Product::Category.find(extra_attributes[:osasto])   if extra_attributes[:osasto]
      product_params[:nakyvyys]    = extra_attributes[:nakyvyys]                         if extra_attributes[:nakyvyys]
      product_params[:status]      = Product::Status.find(extra_attributes[:status])     if extra_attributes[:status]
      product_params[:subcategory] = Product::Subcategory.find(extra_attributes[:try])   if extra_attributes[:try]

      s.create_product(product_params)

      supplier.product_suppliers.create(
        tehdas_saldo:            s.available_quantity,
        tehdas_saldo_paivitetty: Time.now,
        toim_nimitys:            s.product_name,
        toim_tuoteno:            s.product_id,
        tuoteno:                 s.manufacturer_part_number
      )
    end

    unless duplicates.present?
      return redirect_to supplier_product_informations_url, notice: t('.success')
    end

    @supplier_product_informations = duplicates

    flash[:notice] = t('.duplicates_found')
    render :index

  rescue ActionController::ParameterMissing
    redirect_to supplier_product_informations_url(search_params), alert: t('.not_selected')
  end

  private

  def searchable_columns
    %i(
      manufacturer_ean
      manufacturer_part_number
      product_name
      product_id
    )
  end

  def sortable_columns
    searchable_columns
  end

  def supplier_product_informations_params
    permitted = {}

    new_params = params.require(:supplier_product_informations)

    if new_params[:supplier_product_informations]
      new_params[:supplier_product_informations].keys.each do |tunnus|
        permitted[tunnus] = '1'
      end

      new_params.permit(permitted)
    end

    new_params
  end
end

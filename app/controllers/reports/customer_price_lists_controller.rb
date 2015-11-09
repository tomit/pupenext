class Reports::CustomerPriceListsController < ApplicationController
  def create
    return render :index, formats: :html unless params[:commit].present?

    unless params[:osasto] || params[:try]
      flash.now[:alert] = t('.no_filters_specified')
      return render :index, formats: :html
    end

    @products = Product.active

    case params[:target_type].to_i
    when 1 # Customer
      @customer = Customer.find_by(asiakasnro: params[:target])

      unless @customer
        flash.now[:alert] = t('.customer_not_found')
        return render :index, status: :not_found, formats: :html
      end
    when 2 # Customer subcategory
      @customer_subcategory = params[:target]
    else
      return render :index, status: :bad_request, formats: :html
    end

    @products = @products.where(osasto: params[:osasto]) if params[:osasto]
    @products = @products.where(try: params[:try]) if params[:try]
    @products = @products.where(tuotemerkki: params[:tuotemerkki]) if params[:tuotemerkki]

    if @products.empty?
      flash.now[:alert] = t('.products_not_found')
      return render :index, formats: :html
    end

    render pdf:              t('.filename'),
           disposition:      :attachment,
           footer:           { html: { template: 'reports/customer_price_lists/footer.html.erb' } },
           header:           { right: "#{t('.page')} [page] / [toPage]" },
           margin:           { top: 10, bottom: 25 },
           template:         'reports/customer_price_lists/report.html.erb',
           user_style_sheet: Rails.root.join('app',
                                             'assets',
                                             'stylesheets',
                                             'reports',
                                             'pdf_styles.css')
  end
end

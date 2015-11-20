class Reports::CustomerPriceListsController < ApplicationController
  def create
    return render :index unless params_valid?

    @products = params[:product_image] ? Product.includes(:cover_thumbnail).active : Product.active
    @products = @products.where(osasto: params[:osasto]) if params[:osasto]
    @products = @products.where(try: params[:try]) if params[:try]
    @products = @products.where(tuotemerkki: params[:tuotemerkki]) if params[:tuotemerkki]

    if params[:contract_filter].to_i == 2
      @products = @products.select { |p| p.contract_price?(@target) }
    end

    if @products.empty?
      flash.now[:alert] = t('.products_not_found')
      return render :index
    end

    render pdf:         t('.filename'),
           disposition: :attachment,
           footer:      { html: { template: 'reports/customer_price_lists/footer.html.erb' } },
           header:      { right: "#{t('.page')} [page] / [toPage]" },
           template:    'reports/customer_price_lists/report.html.erb'
  end

  private

    def params_valid?
      return false unless params[:commit].present?

      errors = []

      if params[:target].blank?
        errors << t('.customer_not_found')
      end

      unless params[:osasto] || params[:try] || params[:tuotemerkki]
        errors << t('.no_filters_specified')
      end

      case params[:target_type].to_i
      when 1 # Customer
        @customer = Customer.find_by(asiakasnro: params[:target])

        if @customer
          @target = @customer
        else
          errors << t('.customer_not_found')
        end
      when 2 # Customer subcategory
        @customer_subcategory = Keyword::CustomerSubcategory.find_by(tunnus: params[:target])

        if @customer_subcategory
          @target = @customer_subcategory
        else
          errors << t('.customer_subcategory_not_found')
        end
      else
        errors << t('.invalid_target_type')
      end

      if errors.any?
        flash.now[:alert] = errors.to_sentence
        false
      else
        true
      end
    end
end

class Administration::AccountsController < AdministrationController
  with_options only: [:new, :edit, :show] do |options|
    options.before_action :fetch_levels_and_qualifiers
  end

  COLUMNS = [
    :tilino,
    :nimi,
    :sisainen_taso,
    :sisainen_nimi,
    :ulkoinen_taso,
    :ulkoinen_nimi,
    :alv_taso,
    :alv_nimi,
  ]

  sortable_columns *COLUMNS
  default_sort_column :tunnus

  def index
    @accounts = current_company.accounts
    @accounts = @accounts.search_like filter_search_params
    @accounts = @accounts.order("#{sort_column} #{sort_direction}")
  end

  def new
    @account ||= current_company.accounts.build
  end

  def show
    render :edit
  end

  def create
    @account = current_company.accounts.build(account_params)

    if @account.save_by current_user
      redirect_to accounts_path, notice: 'Uusi tili perustettu'
    else
      fetch_levels_and_qualifiers
      render :new
    end
  end

  def edit
  end

  def update
    if @account.update_by account_params, current_user
      redirect_to accounts_path, notice: 'Tili päivitettiin onnistuneesti'
    else
      fetch_levels_and_qualifiers
      render :edit
    end
  end

  def destroy
    @account.destroy
    redirect_to accounts_path, notice: "Tili poistettiin onnistuneesti"
  end

  private

    def account_params
      params.require(:account).permit(
        :tilino,
        :sisainen_taso,
        :ulkoinen_taso,
        :alv_taso,
        :tulosseuranta_taso,
        :nimi,
        :kustp,
        :kohde,
        :toimijaliitos,
        :tiliointi_tarkistus,
        :manuaali_esto,
        :oletus_alv
      )
    end

    def searchable_columns
      COLUMNS
    end

    def find_resource
      @account = current_company.accounts.find params[:id]
    end

    def no_update_access_path
      accounts_path
    end

    def fetch_levels_and_qualifiers
      @levels = {
        internal: current_company.sum_level_internals,
        external: current_company.sum_level_externals,
        vat: current_company.sum_level_vats,
        profit: current_company.sum_level_profits
      }

      @qualifiers = {
        cost_center: current_company.cost_centers,
        target: current_company.targets
      }
    end
end

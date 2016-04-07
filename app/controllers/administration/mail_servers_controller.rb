class Administration::MailServersController < AdministrationController
  def index
    @mail_servers = MailServer.all
  end

  def new
    @mail_server = MailServer.new
  end

  def create
    redirect_to mail_servers_url
  end

  private

    def find_resource
      @mail_server ||= MailServer.find(params[:id])
    end
end

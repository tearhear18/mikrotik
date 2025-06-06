class AgentsController < ApplicationController
  before_action :get_agent, only: %w[show update]

  PERMITTED_PARAMS = %i[name server prefix time_config]

  def update_sales 
    Voucher.fetch
    redirect_to agents_path
  end

  def update
    @agent.update(agent_params)
    @agent.generate_code
    redirect_to @agent
  end

  def code_generator
    @agent = Agent.find(params[:agent_id])
  end

  def create
    Agent.create agent_params
    redirect_to agents_path
  end

  def new
    @agent = Agent.new
  end

  def sales_calculate
    Voucher.fetch
    render json: :ok
    p "Voucher Fetched Called!!!"
    p "Voucher Fetched Called!!!"
    p "Voucher Fetched Called!!!"
  end

  def sales_collected
    Agent.find(params[:agent_id]).sales_collected
    redirect_to agents_path
  end

  def index
    @agents = Agent.all #.order(total_sales: :desc)
  end

  def show
    @vouchers = @agent.vouchers
    time_zone = "Asia/Manila"
    @daily_sales = LoginVoucher.where(agent_id: @agent.id).group_by_day(:login_time, time_zone: time_zone).sum(:price)
  end

  private
  
  def agent_params
    params.require(:agent).permit(PERMITTED_PARAMS)
  end
end

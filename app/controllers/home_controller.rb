class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    # @routers = Router.all
    # empty_index if @routers.empty?
    @vouchers = Voucher.all.order(code: :asc)
    time_zone = "Asia/Manila"
    raw_data = LoginVoucher.where('created_at >= ?',10.days.ago).where.not(agent_id: nil).group(:agent_id).group_by_day(:login_time, time_zone: time_zone).sum(:price)
    today = Time.zone.now.to_date.strftime('%Y-%m-%d')
    @per_agent_daily_sales = raw_data.each_with_object({}) do |((agent_id, date), price), result|
      agent_name = Agent.find(agent_id).name
      result[agent_name] ||= {}
      
      # result[agent_name][date] = price
      if today.to_s === date.to_s
        result[agent_name]['Today'] = price
      else
        result[agent_name][date] = price
      end
    end  
    @over_all_daily_sales = LoginVoucher.where('created_at >= ?',10.days.ago).group_by_day(:login_time, time_zone: time_zone).sum(:price)
  end

  def create

  end

  def empty_index
    render 'empty_index'
  end
end

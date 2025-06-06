class AgentDocumentsController < ApplicationController
  before_action :get_agent, only: %[show]

  PDF_PRAWN_MAX_COL = 4
  PDF_PRAWN_CELL_HEIGHT = 36

  def index
    @document = @agent.agent_documents.find(params[:id])
  end

  def show
    @document = @agent.agent_documents.find(params[:id])

    respond_to do |format|
      format.html do
        @vouchers_stats = @document.vouchers.group(:limit_uptime).count
        @vouchers_expired = @document.vouchers.expired.group(:limit_uptime).count
        @vouchers_available = @document.vouchers.available.group(:limit_uptime).count
      end
      format.pdf do
        @vouchers = @document.vouchers.in_mikrotik
        pdf = Prawn::Document.new(page_size: [612, 1000])
        table_data = Array.new

        marker = 1
        _cols = []
        @vouchers.each do |voucher|
          if(marker == PDF_PRAWN_MAX_COL)
            _cols << code_format(voucher.code)
            _cols << price_format( voucher )
            table_data << _cols
            _cols = []
            marker = 1
          else
            marker+=1
            _cols << code_format(voucher.code)
            _cols << price_format( voucher )
          end
        end
        pdf.table(table_data, :width => 560, :cell_style => { :inline_format => true,:border_color => "000000",:border_width => 1, })
        send_data pdf.render, filename: "#{@document.name}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end

    # @vouchers = @agent.agent_documents.find(params[:id]).vouchers.in_mikrotik
  end

  def destroy
    agent = Agent.find(params[:agent_id])
    document = agent.agent_documents.find(params[:id])
    document.remove_vouchers
    redirect_to agent_path(agent)
  end

  def code_format( val )
    {:content => val,:size => 15, :text_color => "000000",height: PDF_PRAWN_CELL_HEIGHT,valign: :center, align: :right,:padding => [0,10,8,0]}
  end

  def price_format( voucher )
    price_label = ActionController::Base.helpers.number_to_currency((voucher.time_set.to_i / voucher.agent.multiplier ) * 5, unit:'',separator: ".", delimiter: ",")
    {
      :content => "-------- #{price_label}",
      :text_color => "000000",
      :rotate => 90, :size => 7,width: 20, height: PDF_PRAWN_CELL_HEIGHT,valign: :bottom,align: :center,:padding => [0,0,0,1]
    }
  end

  private

  def get_agent
    @agent = Agent.find(params[:agent_id])
  end

end

class ApplicationController < ActionController::Base
    def get_agent
        @agent = Agent.find(params[:id])
    end
end

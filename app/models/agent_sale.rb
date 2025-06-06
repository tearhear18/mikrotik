class AgentSale < ApplicationRecord

    def collected
        update is_collected: true
    end
end

class AgentDocument < ApplicationRecord
    has_many :vouchers, dependent: :destroy
    belongs_to :agent
    def remove_vouchers
        vouchers.each do |v|
            VoucherDeleteWorker.perform_async(v.code)
        end
    end
end

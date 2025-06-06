class Agent < ApplicationRecord
    has_many :vouchers
    has_many :agent_sales
    has_many :agent_documents
    before_save :parse_time_config
    has_many :login_vouchers

    RATE_PER_HOUR = 5.to_d
    MAX_CODE_CAN_BE_GENERATED = 100


    def parse_time_config
        self.time_config = JSON.parse(self[:time_config].gsub('=>', ':'))
    end

    def actual_sales 
        login_vouchers.sum(:price)
    end

    class << self
        def calculate_sales
            find_each do |agent|
                today_sales = agent.agent_sales.where("created_at > ?",Time.current.beginning_of_day)

                total_sales = 0.to_d

                agent.vouchers.expired.find_each do |voucher|
                    next if voucher.agent_document.nil?
                    total_sales += ( voucher.time_set.to_d / voucher.agent_document.multiplier.to_d ) * RATE_PER_HOUR
                end
                agent.agent_sales.create amount: total_sales
                agent.update_column(:total_sales,total_sales)
            end
        end

        def calculate_sales_by_document
            find_each do |agent|
                next if agent.agent_documents.empty?
                total_sales = 0.to_d
                agent.agent_documents.last.vouchers.expired.find_each do |voucher|
                    total_sales += ( voucher.time_set.to_d / agent.multiplier.to_d ) * RATE_PER_HOUR
                end
                agent.agent_documents.last.update sale_amount: total_sales
            end
        end
    end

    def sales_collected
        login_vouchers.update_all is_collected: true
    end

    def last_collected_amount
        agent_sales.where(is_collected: true).last&.amount || 0
    end

    def estimated_collectible
        login_vouchers.not_collected.sum(:price)
    end

    def generate_code
        doc = agent_documents.create name: "#{prefix}_#{Time.current.to_i}", multiplier: multiplier
        _vouchers = []
        time_config.each do |config|
            code_limit = config[1].split("|").last.to_i
            code_limit.times do
                v = Voucher.generate( prefix,config[0])
                while _vouchers.pluck(:code).include? v.code do
                    v = Voucher.generate( prefix,config[0])
                end
                v.limit_uptime = "#{config[0]}h"
                v.agent_id = id
                v.agent_document_id = doc.id
                puts "added: #{v.code}"
                puts "size: #{_vouchers.size}"
                _vouchers << v
            end
        end
        Voucher.import(_vouchers)
        _vouchers.each do |v|
            VoucherRegisterWorker.perform_async(v.code)
        end
    end
end

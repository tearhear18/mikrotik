class VoucherRegisterWorker
    include Sidekiq::Worker
    include Sidekiq::Job
    sidekiq_options queue: 'voucher_que'

    def perform( code )
        Voucher.find_by_code(code).register_to_mikrotik
    end
end
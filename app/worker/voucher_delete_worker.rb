class VoucherDeleteWorker
    include Sidekiq::Worker

    def perform code
        Voucher.remove( code )
    end
end
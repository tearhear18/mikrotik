class VoucherUpdateWorker
    include Sidekiq::Worker
    include Sidekiq::Job

    sidekiq_options queue: 'voucher_que'

    def perform( code , server_name )
        puts "updating : #{code} -> server: #{server_name}"
        Voucher.find_by_code(code).update_server(server_name)
    end
end
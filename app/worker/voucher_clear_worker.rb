class VoucherClearWorker
    include Sidekiq::Worker

    def perform
        Voucher::TIME_RANGE.keys.each do |filter|
            puts "Time Range: #{filter}"
            Voucher.where("limit_uptime = ? && uptime like ? && in_mikrotik = ?",filter,"%#{filter}%",true).find_each do |voucher|
                begin
                    VoucherDeleteWorker.perform_async(voucher.code)
                    # url = URI("https://192.168.110.2/rest/ip/hotspot/user/#{voucher.code}")
                    # https = Net::HTTP.new(url.host, url.port)
                    # https.use_ssl = true
                    # https.verify_mode = OpenSSL::SSL::VERIFY_NONE
                    # request = Net::HTTP::Delete.new(url)
                    # request["Authorization"] = "Basic YWRtaW46Q3M0OW91cG91aiEhISE="
                    # response = https.request(request)

                    # voucher.update in_mikrotik: false
                    # puts "code: #{voucher.code} delete!"
                rescue => exception
                    next
                end
            end
        end
    end
end
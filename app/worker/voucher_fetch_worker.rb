class VoucherFetchWorker
    include Sidekiq::Worker

    def perform
        puts "Starting to request"
        RawVoucher.delete_all
        url = URI("https://192.168.110.2/rest/ip/hotspot/user")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(url)
        request["Authorization"] = "Basic YWRtaW46Q3M0OW91cG91aiEhISE="
        request["Content-Type"] = "application/json"
        vouchers_str = https.request(request).read_body

        vouchers = JSON.parse vouchers_str
        voucher_arr = []

        vouchers.each do |voucher|
            voucher_arr << {
                code: voucher["name"],
                profile: voucher["profile"],
                limit_uptime: voucher["limit-uptime"],
                uptime: voucher["uptime"],
                status: true
            }
        end
        RawVoucher.import voucher_arr

        puts "Performing Voucher Updates"
        Voucher.perform_update

        puts "Performing Agent Sales"
        Agent.calculate_sales

        Agent.calculate_sales_by_document
    end
end
require "uri"
require "json"
require "net/http"

class Mikrotik
    attr_accessor :host
    def initialize
        @host = "192.168.20.1"
    end

    def fetch_vouchers
        url = URI("https://192.168.110.2/rest/ip/hotspot/user")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["Authorization"] = "Basic YWRtaW46Q3M0OW91cG91aiEhISE="
        request["Content-Type"] = "application/json"
        request.body = JSON.dump({
        "mac-address": ""
        })

        response = https.request(request)
        puts response.read_body
    end
end
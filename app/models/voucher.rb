require "uri"
require "net/http"

class Voucher < ApplicationRecord

    belongs_to :agent, optional: true
    belongs_to :agent_document, optional: true
    validates_uniqueness_of :code
    validates_presence_of :code

    before_destroy :unregister_to_mikrotik
    
    scope :expired, lambda {
        where(status: false)
    }
    scope :available, lambda {
        where(status: true, in_mikrotik: true)
    }
    scope :active_count, lambda {
        where(status: true, in_mikrotik: true).count
    }
    scope :in_mikrotik, lambda {
        where(in_mikrotik: true)
    }
    DEFAULT_MTK_PROFILE = "1M-BAND".freeze

    TIME_RANGE = {
        "1h"=> 1,
        "2h"=> 2,
        "3h"=> 3,
        "4h"=> 4,
        "6h"=> 6,
        "8h"=> 8,
        "10h"=> 10
    }

    class << self
        def update_server_name( server_name )
            vouchers = Agent.find(10).vouchers.in_mikrotik
            # vouchers = Voucher.available.where.not(agent_id: 11)
            vouchers.each do |voucher|
                VoucherUpdateWorker.perform_async( voucher.code, server_name )
            end
        end

        def clear_past_code
            vouchers = Voucher.where("created_at < ? && in_mikrotik = ? && uptime != ?",Time.current - 20.days,true,"0s")
            vouchers.each do |v|
                VoucherDeleteWorker.perform_async( v.code )
            end
        end

        def clear_code
            Voucher::TIME_RANGE.keys.each do |filter|
                Voucher.where("limit_uptime = ? && uptime like ? && in_mikrotik = ? && created_at < ?",filter,"%#{filter}%",true,10.days.ago).find_each do |voucher|
                    begin
                        VoucherDeleteWorker.perform_async(voucher.code)
                    rescue => exception
                        next
                    end
                end
            end
            # VoucherClearWorker.perform_async
        end

        def fetch
            fetcher = MikrotikDataFetcher.new(
                host: '192.168.110.2',
                username: 'admin',
                password: 'Cs49oupouj!!!!',
                file_path: 'hotspot/data/data.txt'
            )
            @data = fetcher.fetch_data
            LoginVoucher.import @data, on_duplicate_key_ignore: true

            puts "Performing Voucher Updates"
            perform_update

            sleep 1
            LoginVoucher.map_agent
            puts "DONE!!!"
        end

        def perform_update
            main = Agent.find_by_name "Main"
            # only deal with uptime != 0s
            LoginVoucher.not_imported.find_each do |voucher|
                mVoucher = Voucher.find_by_code(voucher.voucher_code )
                voucher.update is_imported: true
                next if mVoucher.nil?
                
                mVoucher.update({
                    status: false,
                    in_mikrotik: true
                })
            end
        end

        def add_time code,time_hour

            url = URI("https://192.168.110.2/rest/ip/hotspot/user/#{code}")
            https = Net::HTTP.new(url.host, url.port)
            https.use_ssl = true
            https.verify_mode = OpenSSL::SSL::VERIFY_NONE

            request = Net::HTTP::Patch.new(url)
            request["Authorization"] = "Basic YWRtaW46Q3M0OW91cG91aiEhISE="
            request["Content-Type"] = "application/json"

            # vouchers = JSON.parse https.request(request).read_body
        end

        def remove code
            _voucher = Voucher.find_by_code( code )

            if _voucher.present?
                url = URI("https://192.168.110.2/rest/ip/hotspot/user/#{code}")
                https = Net::HTTP.new(url.host, url.port)
                https.use_ssl = true
                https.verify_mode = OpenSSL::SSL::VERIFY_NONE

                request = Net::HTTP::Delete.new(url)
                request["Authorization"] = "Basic YWRtaW46Q3M0OW91cG91aiEhISE="
                request["Content-Type"] = "application/json"
                response = https.request(request)
                _voucher.update in_mikrotik: false
                p "#{code} code deleted!"
            end
        end

        def generate( prefix, time )
            voucher = new
            voucher.code = "#{prefix}-#{time}#{SecureRandom.random_number(10**8).to_s.rjust(8, '0')}"
            voucher.profile = DEFAULT_MTK_PROFILE
            voucher.in_mikrotik = false
            voucher.status = true
            voucher.time_set = time.to_i
            while voucher.invalid?
                voucher.code = "#{prefix}-#{time}#{SecureRandom.hex(2).upcase}"
            end
            voucher
        end
    end

    def register_to_mikrotik
        params = {
            "server" => agent.server,
            "name" => code,
            "profile"=> profile,
            "limit-uptime" => limit_uptime,
        }
        url = URI("https://192.168.110.2/rest/ip/hotspot/user")
            https = Net::HTTP.new(url.host, url.port)
            https.use_ssl = true
            https.verify_mode = OpenSSL::SSL::VERIFY_NONE

            request = Net::HTTP::Put.new(url)
            request["Authorization"] = "Basic YWRtaW46Q3M0OW91cG91aiEhISE="
            request["Content-Type"] = "application/json"
            request.body = params.to_json
            
            if https.request(request).code.to_i == 201
                update( in_mikrotik:true)
                p "register to mikrotik success"
            else
                p "Code Exist #{code}"
            end
    end

    def unregister_to_mikrotik
        url = URI("https://192.168.110.2/rest/ip/hotspot/user/#{code}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Delete.new(url)
        request["Authorization"] = "Basic YWRtaW46Q3M0OW91cG91aiEhISE="
        request["Content-Type"] = "application/json"
        response = https.request(request)
        update in_mikrotik: false
        p "unregister to mikrotik success"
    end

    def update_server( server_name )
        url = URI("https://192.168.110.2/rest/ip/hotspot/user/#{code}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Patch.new(url)
        request.body = JSON.dump({
            "server": server_name
        })
        request["Authorization"] = "Basic YWRtaW46Q3M0OW91cG91aiEhISE="
        request["Content-Type"] = "application/json"

        res = https.request(request)
        if res.code.to_i == 200
            p "success!"
        else
            p "failed!"
        end
    end
end

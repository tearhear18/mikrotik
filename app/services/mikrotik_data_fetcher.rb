# app/services/mikrotik_data_fetcher.rb
require 'net/ssh'

class MikrotikDataFetcher
  def initialize(host:, username:, password:, file_path:)
    @host = host
    @username = username
    @password = password
    @file_path = file_path
  end

  def fetch_data
    data = ""
    Net::SSH.start(@host, @username, password: @password) do |ssh|
      ssh.exec!("system script run read_file_contents") do |channel, stream, output|
        if stream == :stdout
          data << output
        end
      end
    end
    parse_data(data)
  end

  private

  def parse_data(data)
    # Assuming the data is in CSV format
    data.lines.map do |line|
      datetime, voucher_code = line.strip.split(", ")
      datetime = ActiveSupport::TimeZone["Asia/Manila"].parse(datetime)
      { login_time: datetime, voucher_code: voucher_code }
    end
  end
end

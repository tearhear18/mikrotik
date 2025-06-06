class LoginVoucher < ApplicationRecord
  scope :not_imported, -> { where(is_imported: false) }

  belongs_to :agent, optional: true

  scope :not_collected, ->{ where(is_collected: false) }
  
  def self.map_agent
    puts "MAPPING AGENT FOR LOGIN VOUCHER"
    LoginVoucher.where(agent_id: nil).find_each do |lv|
      voucher = Voucher.find_by_code(lv.voucher_code)
      next if voucher.nil?

      puts "Mapping agent for voucher: #{lv.voucher_code}"
      prices = {
        '2h' => 5,
        '3h' => 5,
        '4h' => 10,
        '6h' => 10,
        '8h' => 20
      }
      price = prices[voucher.limit_uptime]
      lv.update(agent_id: voucher.agent_id, price: price)
    end
  end
end

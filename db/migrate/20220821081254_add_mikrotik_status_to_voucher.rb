class AddMikrotikStatusToVoucher < ActiveRecord::Migration[6.1]
  def change
    add_column :vouchers, :in_mikrotik, :boolean, default: true
  end
end

class AddAgentIdToLoginVoucher < ActiveRecord::Migration[6.1]
  def change
    add_reference :login_vouchers, :agent, index: true
    add_column :login_vouchers, :is_collected, :boolean, :default => false
    add_column :login_vouchers, :price, :decimal , :precision => 8, :scale => 2
  end
end

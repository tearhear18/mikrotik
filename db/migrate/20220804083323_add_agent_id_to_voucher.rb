class AddAgentIdToVoucher < ActiveRecord::Migration[6.1]
  def change
    add_reference :vouchers, :agent, index: true
    add_column :vouchers, :time_set, :string
  end
end

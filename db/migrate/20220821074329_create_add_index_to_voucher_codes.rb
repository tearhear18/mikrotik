class CreateAddIndexToVoucherCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :add_index_to_voucher_codes do |t|
      add_index :vouchers, :code, unique: true
      t.timestamps
    end
  end
end

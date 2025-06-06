class CreateLoginVouchers < ActiveRecord::Migration[6.1]
  def change
    create_table :login_vouchers do |t|
      t.datetime :login_time
      t.string :voucher_code
      t.timestamps
      t.boolean :is_imported, default: false
      t.index :voucher_code, unique: true
    end
  end
end

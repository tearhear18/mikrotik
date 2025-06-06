class CreateRawVouchers < ActiveRecord::Migration[6.1]
  def change
    create_table :raw_vouchers do |t|
      t.string :tag
      t.string :code
      t.string :limit_uptime
      t.string :uptime
      t.string :profile
      t.boolean :status, default: true
      t.timestamps
    end
  end
end

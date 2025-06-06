class AddReferenceDocRefToVoucher < ActiveRecord::Migration[6.1]
  def change
    add_reference :vouchers, :agent_document, index: true
  end
end

class CreateAgentSales < ActiveRecord::Migration[6.1]
  def change
    create_table :agent_sales do |t|
      t.decimal :amount
      t.belongs_to :agent, index:true
      t.timestamps
    end
  end
end

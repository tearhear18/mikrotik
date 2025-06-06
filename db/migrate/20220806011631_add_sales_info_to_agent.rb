class AddSalesInfoToAgent < ActiveRecord::Migration[6.1]
  def change
    add_column :agents, :multiplier, :integer
    add_column :agents, :total_sales, :integer
  end
end

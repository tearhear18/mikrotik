class AddCollectedToAgentDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :agent_sales, :is_collected, :boolean, default: false
  end
end
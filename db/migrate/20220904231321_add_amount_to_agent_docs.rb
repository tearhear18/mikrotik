class AddAmountToAgentDocs < ActiveRecord::Migration[6.1]
  def change
    add_column :agent_documents, :sale_amount, :decimal
  end
end

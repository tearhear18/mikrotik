class AddMultiplierToAgentDocument < ActiveRecord::Migration[6.1]
  def change
    add_column :agent_documents, :multiplier, :integer, default: 1
  end
end

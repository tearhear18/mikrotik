class CreateAgentDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :agent_documents do |t|
      t.string :name
      t.belongs_to :agent, index:true
      t.timestamps
    end
  end
end

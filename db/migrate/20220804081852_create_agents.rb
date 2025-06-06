class CreateAgents < ActiveRecord::Migration[6.1]
  def change
    create_table :agents do |t|
      t.string :prefix
      t.string :name
      t.integer :total_code
      t.timestamps
    end
  end
end

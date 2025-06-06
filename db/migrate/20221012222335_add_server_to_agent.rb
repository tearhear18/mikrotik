class AddServerToAgent < ActiveRecord::Migration[6.1]
  def change
    add_column :agents, :server, :string
  end
end

class AddSourcedIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :sourced_id, :string, after: :id
    add_index :users, :sourced_id, unique: true
  end
end

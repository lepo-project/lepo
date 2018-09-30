class RemoveFolderNameFromUsers < ActiveRecord::Migration[5.0]
  def up
    remove_index :users, :folder_name
    remove_column :users, :folder_name
  end

  def down
    add_column :users, :folder_name, :string
    add_index :users, :folder_name, unique: true
  end
end

class RenameColumnFolderIdInUsersToFolderName < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :folder_id, :folder_name
  end
end

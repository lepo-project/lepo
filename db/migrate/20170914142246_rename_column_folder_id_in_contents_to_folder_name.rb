class RenameColumnFolderIdInContentsToFolderName < ActiveRecord::Migration[5.0]
  def change
    rename_column :contents, :folder_id, :folder_name
  end
end

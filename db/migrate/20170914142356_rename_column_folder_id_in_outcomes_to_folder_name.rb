class RenameColumnFolderIdInOutcomesToFolderName < ActiveRecord::Migration[5.0]
  def change
    rename_column :outcomes, :folder_id, :folder_name
  end
end

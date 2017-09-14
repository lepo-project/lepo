class RenameColumnFolderIdInCoursesToFolderName < ActiveRecord::Migration[5.0]
  def change
    rename_column :courses, :folder_id, :folder_name
  end
end

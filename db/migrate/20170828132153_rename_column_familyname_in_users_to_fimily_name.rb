class RenameColumnFamilynameInUsersToFimilyName < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :familyname, :family_name
  end
end

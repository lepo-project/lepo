class RenameColumnFamilynameAltInUsersToPhoneticFimilyName < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :familyname_alt, :phonetic_family_name
  end
end

class RenameColumnGivennameAltInUsersToPhoneticGivenName < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :givenname_alt, :phonetic_given_name
  end
end

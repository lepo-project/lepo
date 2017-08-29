class RenameColumnGivennameInUsersToGivenName < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :givenname, :given_name
  end
end

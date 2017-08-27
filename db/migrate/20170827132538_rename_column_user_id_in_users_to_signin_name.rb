class RenameColumnUserIdInUsersToSigninName < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :user_id, :signin_name
  end
end

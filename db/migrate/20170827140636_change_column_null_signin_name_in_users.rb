class ChangeColumnNullSigninNameInUsers < ActiveRecord::Migration[5.0]
  def change
    change_column_null :users, :signin_name, false
  end
end

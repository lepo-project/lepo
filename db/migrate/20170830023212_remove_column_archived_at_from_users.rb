class RemoveColumnArchivedAtFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :archived_at, :datetime
  end
end

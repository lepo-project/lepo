class AddTargetIdToBookmarks < ActiveRecord::Migration[5.0]
  def change
    add_column :bookmarks, :target_id, :integer, after: :title
    add_index :bookmarks, :target_id
  end
end

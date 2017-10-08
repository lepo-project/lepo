class AddTargetTypeToBookmarks < ActiveRecord::Migration[5.0]
  def change
    add_column :bookmarks, :target_type, :string, default: 'web', after: :target_id
  end
end

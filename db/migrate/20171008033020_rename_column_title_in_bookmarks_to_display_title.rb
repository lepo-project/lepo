class RenameColumnTitleInBookmarksToDisplayTitle < ActiveRecord::Migration[5.0]
  def change
    rename_column :bookmarks, :title, :display_title
  end
end

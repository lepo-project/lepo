class RenameLinksToBookmarks < ActiveRecord::Migration[5.0]
  def change
    rename_table :links, :bookmarks
  end
end

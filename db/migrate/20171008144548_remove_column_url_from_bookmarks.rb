class RemoveColumnUrlFromBookmarks < ActiveRecord::Migration[5.0]
  def up
    remove_column :bookmarks, :url
  end

  def down
    add_column :bookmarks, :url, :text
  end
end

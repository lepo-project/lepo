class RenameWebSourcesToWebPages < ActiveRecord::Migration[5.0]
  def change
    rename_table :web_sources, :web_pages
  end
end

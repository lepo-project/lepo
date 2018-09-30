class DropSnippetFiles < ActiveRecord::Migration[5.0]
  def change
    drop_table :snippet_files
  end
end

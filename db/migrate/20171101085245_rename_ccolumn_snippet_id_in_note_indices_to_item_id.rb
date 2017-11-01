class RenameCcolumnSnippetIdInNoteIndicesToItemId < ActiveRecord::Migration[5.0]
  def up
    remove_index :note_indices, %i[snippet_id note_id]
    rename_column :note_indices, :snippet_id, :item_id
  end

  def down
    rename_column :note_indices, :item_id, :snippet_id
    add_index :note_indices, %i[snippet_id note_id], unique: true
  end
end

class RemoveNoteIdFromSnippets < ActiveRecord::Migration[5.0]
  def up
    remove_column :snippets, :note_id
  end

  def down
    add_column :snippets, :note_id, :integer
    add_index :snippets, :note_id
  end
end

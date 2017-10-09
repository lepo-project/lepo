class CreateNoteIndices < ActiveRecord::Migration[5.0]
  def change
    create_table :note_indices do |t|
      t.integer :note_id
      t.integer :snippet_id
      t.integer :display_order

      t.timestamps
    end
    add_index :note_indices, :note_id
    add_index :note_indices, %i[snippet_id note_id], unique: true
  end
end

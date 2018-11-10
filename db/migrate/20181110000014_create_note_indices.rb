class CreateNoteIndices < ActiveRecord::Migration[5.0]
  def change
    create_table :note_indices do |t|
      t.integer :note_id
      t.integer :item_id
      t.string  :item_type, default: 'Snippet'
      t.integer :display_order

      t.timestamps
    end
    add_index :note_indices, :note_id
    add_index :note_indices, %i[item_id item_type note_id], unique: true
  end
end

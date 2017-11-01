class AddItemTypeToNoteIndices < ActiveRecord::Migration[5.0]
  def change
    add_column :note_indices, :item_type, :string, default: 'Snippet', after: :item_id
    add_index :note_indices, %i[item_id item_type note_id], unique: true
  end
end

class RenameColumnOriginalNoteIdInNotesToOriginalWsId < ActiveRecord::Migration[5.0]
  def change
    rename_column :notes, :original_note_id, :original_ws_id
  end
end

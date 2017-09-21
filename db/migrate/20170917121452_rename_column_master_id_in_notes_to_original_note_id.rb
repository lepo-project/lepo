class RenameColumnMasterIdInNotesToOriginalNoteId < ActiveRecord::Migration[5.0]
  def change
    rename_column :notes, :master_id, :original_note_id
  end
end

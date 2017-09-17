class ChangeStatusDefaultInNotes < ActiveRecord::Migration[5.0]
  def up
    change_column_default :notes, :status, 'draft'
  end

  def down
    change_column_default :notes, :status, 'private'
  end
end

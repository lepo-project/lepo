class ChangeCourseIdDefaultInNotes < ActiveRecord::Migration[5.0]
  def change
    change_column_default :notes, :course_id, 0
  end
end

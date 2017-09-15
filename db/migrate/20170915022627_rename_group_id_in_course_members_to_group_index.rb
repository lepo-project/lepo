class RenameGroupIdInCourseMembersToGroupIndex < ActiveRecord::Migration[5.0]
  def change
    rename_column :course_members, :group_id, :group_index
  end
end

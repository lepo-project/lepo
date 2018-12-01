class RenameCourseMembersToEnrollments < ActiveRecord::Migration[5.0]
  def change
    rename_table :course_members, :enrollments
  end
end

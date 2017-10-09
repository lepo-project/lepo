class CreateCourseMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :course_members do |t|
      t.integer :course_id
      t.integer :user_id
      t.string :role
      t.integer :group_index, default: 0

      t.timestamps
    end
    add_index :course_members, :group_index
    add_index :course_members, %i[user_id course_id], unique: true
  end
end

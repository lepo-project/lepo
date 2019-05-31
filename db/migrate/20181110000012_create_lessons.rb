class CreateLessons < ActiveRecord::Migration[5.0]
  def change
    create_table :lessons do |t|
      t.integer :evaluator_id
      t.integer :content_id
      t.integer :course_id
      t.integer :display_order
      t.string :status
      t.datetime :attendance_start_at
      t.datetime :attendance_end_at
      t.timestamps
    end
    add_index :lessons, :course_id
    add_index :lessons, %i[content_id course_id], unique: true
  end
end

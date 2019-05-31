class CreateOutcomes < ActiveRecord::Migration[5.0]
  def change
    create_table :outcomes do |t|
      t.integer :manager_id
      t.integer :course_id
      t.integer :lesson_id
      t.string :folder_name
      t.string :status, default: 'draft'
      t.integer :score
      t.boolean :checked

      t.timestamps
    end
    add_index :outcomes, :course_id
    add_index :outcomes, :lesson_id
    add_index :outcomes, %i[manager_id lesson_id], unique: true
  end
end

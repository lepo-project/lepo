class CreateGoals < ActiveRecord::Migration[5.0]
  def change
    create_table :goals do |t|
      t.integer :course_id
      t.string :title

      t.timestamps
    end
    add_index :goals, :course_id
  end
end

class CreateGoalsObjectives < ActiveRecord::Migration[5.0]
  def change
    create_table :goals_objectives do |t|
      t.integer :lesson_id
      t.integer :goal_id
      t.integer :objective_id

      t.timestamps
    end
    add_index :goals_objectives, :goal_id
    add_index :goals_objectives, :lesson_id
    add_index :goals_objectives, %i[objective_id goal_id], unique: true
  end
end

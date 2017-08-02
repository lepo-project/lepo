class CreateOutcomesObjectives < ActiveRecord::Migration[5.0]
  def change
    create_table :outcomes_objectives do |t|
      t.integer :outcome_id
      t.integer :objective_id
      t.integer :self_achievement
      t.integer :eval_achievement

      t.timestamps
    end
    add_index :outcomes_objectives, %i[outcome_id objective_id], unique: true
  end
end

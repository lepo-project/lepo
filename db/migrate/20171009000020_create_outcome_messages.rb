class CreateOutcomeMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :outcome_messages do |t|
      t.integer :manager_id
      t.integer :outcome_id
      t.text :message
      t.integer :score

      t.timestamps
    end
    add_index :outcome_messages, :manager_id
    add_index :outcome_messages, :outcome_id
  end
end

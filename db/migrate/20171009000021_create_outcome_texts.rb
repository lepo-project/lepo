class CreateOutcomeTexts < ActiveRecord::Migration[5.0]
  def change
    create_table :outcome_texts do |t|
      t.integer :outcome_id
      t.text :entry

      t.timestamps
    end
    add_index :outcome_texts, :outcome_id
  end
end

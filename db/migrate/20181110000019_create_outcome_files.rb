class CreateOutcomeFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :outcome_files do |t|
      t.integer :outcome_id
      t.text :upload_data

      t.timestamps
    end
    add_index :outcome_files, :outcome_id
  end
end

class CreateOutcomeFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :outcome_files do |t|
      t.integer :outcome_id
      t.string :upload_file_name
      t.string :upload_content_type
      t.integer :upload_file_size
      t.datetime :upload_updated_at

      t.timestamps
    end
    add_index :outcome_files, :outcome_id
  end
end

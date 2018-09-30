class RemovePaperclipColumnsFromOutcomeFiles < ActiveRecord::Migration[5.0]
  def up
    remove_column :outcome_files, :upload_file_name
    remove_column :outcome_files, :upload_content_type
    remove_column :outcome_files, :upload_file_size
    remove_column :outcome_files, :upload_updated_at
  end

  def down
    add_column :outcome_files, :upload_file_name, :string
    add_column :outcome_files, :upload_content_type, :string
    add_column :outcome_files, :upload_file_size, :integer
    add_column :outcome_files, :upload_updated_at, :datetime
  end
end

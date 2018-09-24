class AddUploadDataToOutcomeFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :outcome_files, :upload_data, :text, after: :outcome_id
  end
end

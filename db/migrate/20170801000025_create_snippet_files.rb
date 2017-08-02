class CreateSnippetFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :snippet_files do |t|
      t.integer :snippet_id
      t.string :upload_file_name
      t.string :upload_content_type
      t.integer :upload_file_size
      t.datetime :upload_updated_at

      t.timestamps
    end
    add_index :snippet_files, :snippet_id
  end
end

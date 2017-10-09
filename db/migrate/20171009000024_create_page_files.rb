class CreatePageFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :page_files do |t|
      t.integer :content_id
      t.integer :display_order
      t.string :upload_file_name
      t.string :upload_content_type
      t.integer :upload_file_size
      t.datetime :upload_updated_at

      t.timestamps
    end
    add_index :page_files, :content_id
  end
end

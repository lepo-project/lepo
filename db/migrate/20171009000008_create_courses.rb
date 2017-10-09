class CreateCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :courses do |t|
      t.integer :term_id
      t.string :folder_name
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.string :title
      t.text :overview
      t.string :status, default: 'draft'
      t.integer :groups_count, default: 1

      t.timestamps
    end
    add_index :courses, :term_id
    add_index :courses, :folder_name, unique: true
  end
end

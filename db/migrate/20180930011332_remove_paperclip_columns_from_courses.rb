class RemovePaperclipColumnsFromCourses < ActiveRecord::Migration[5.0]
  def up
    remove_column :courses, :image_file_name
    remove_column :courses, :image_content_type
    remove_column :courses, :image_file_size
    remove_column :courses, :image_updated_at
  end

  def down
    add_column :courses, :image_file_name, :string
    add_column :courses, :image_content_type, :string
    add_column :courses, :image_file_size, :integer
    add_column :courses, :image_updated_at, :datetime
  end
end

class RemoveFolderNameFromCourses < ActiveRecord::Migration[5.0]
  def up
    remove_index :courses, :folder_name
    remove_column :courses, :folder_name
  end

  def down
    add_column :courses, :folder_name, :string
    add_index :courses, :folder_name, unique: true
  end
end

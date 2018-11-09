class AddGuidToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :guid, :string, after: :id
    add_index :courses, :guid, unique: true
  end
end

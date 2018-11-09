class AddEnabledToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :enabled, :boolean, default: true, after: :id
    add_index :courses, :enabled
  end
end

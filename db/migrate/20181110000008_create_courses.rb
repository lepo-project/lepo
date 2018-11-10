class CreateCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :courses do |t|
      t.boolean :enabled, default: true
      t.string :guid
      t.integer :term_id
      t.text :image_data
      t.string :title
      t.text :overview
      t.integer :weekday, default: 9
      t.integer :period, default: 0
      t.string :status, default: 'draft'
      t.integer :groups_count, default: 1

      t.timestamps
    end
    add_index :courses, :enabled
    add_index :courses, :guid, unique: true
    add_index :courses, :term_id
  end
end

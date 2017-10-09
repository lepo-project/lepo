class CreateStickies < ActiveRecord::Migration[5.0]
  def change
    create_table :stickies do |t|
      t.integer :manager_id
      t.integer :content_id
      t.integer :course_id
      t.integer :target_id
      t.string :target_type, default: 'page'
      t.integer :stars_count, default: 0
      t.string :category, default: 'private'
      t.text :message

      t.timestamps
    end
    add_index :stickies, :content_id
    add_index :stickies, :course_id
    add_index :stickies, :target_id
  end
end

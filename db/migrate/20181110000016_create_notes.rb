class CreateNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :notes do |t|
      t.integer :manager_id
      t.integer :course_id, default: 0
      t.integer :original_ws_id, default: 0
      t.string :title
      t.text :overview
      t.string :category, default: 'private'
      t.string :status, default: 'draft'
      t.integer :stars_count, default: 0
      t.integer :peer_reviews_count, default: 0

      t.timestamps
    end
    add_index :notes, :manager_id
    add_index :notes, :course_id
    add_index :notes, :original_ws_id
    add_index :notes, :category
  end
end

class CreateNoteStars < ActiveRecord::Migration[5.0]
  def change
    create_table :note_stars do |t|
      t.integer :manager_id
      t.integer :note_id
      t.boolean :stared, default: true

      t.timestamps
    end
    add_index :note_stars, :note_id
    add_index :note_stars, %i[manager_id note_id], unique: true
  end
end

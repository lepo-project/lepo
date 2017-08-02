class CreateStickyStars < ActiveRecord::Migration[5.0]
  def change
    create_table :sticky_stars do |t|
      t.integer :manager_id
      t.integer :sticky_id
      t.boolean :stared, default: true

      t.timestamps
    end
    add_index :sticky_stars, :sticky_id
    add_index :sticky_stars, %i[manager_id sticky_id], unique: true
  end
end

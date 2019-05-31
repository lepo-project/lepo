class CreateBookmarks < ActiveRecord::Migration[5.0]
  def change
    create_table :bookmarks do |t|
      t.integer :manager_id
      t.integer :display_order
      t.string :display_title
      t.integer :target_id
      t.string :target_type, default: 'web'

      t.timestamps
    end
    add_index :bookmarks, %i[manager_id display_title], unique: true
    add_index :bookmarks, :target_id
  end
end

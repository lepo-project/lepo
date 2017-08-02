class CreateContents < ActiveRecord::Migration[5.0]
  def change
    create_table :contents do |t|
      t.string :category
      t.string :folder_id
      t.string :title
      t.text :condition
      t.text :overview
      t.string :status, default: 'open'
      t.string :as_category, default: 'text'
      t.text :as_overview

      t.timestamps
    end
    add_index :contents, :folder_id, unique: true
  end
end

class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.integer :manager_id
      t.integer :display_order
      t.text :url
      t.string :title

      t.timestamps
    end
    add_index :links, %i[manager_id title], unique: true
  end
end

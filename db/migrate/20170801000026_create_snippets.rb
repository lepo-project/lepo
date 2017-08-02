class CreateSnippets < ActiveRecord::Migration[5.0]
  def change
    create_table :snippets do |t|
      t.integer :manager_id
      t.integer :note_id
      t.string :category, default: 'text'
      t.text :description
      t.string :source_type, default: 'direct'
      t.integer :source_id
      t.integer :master_id
      t.integer :display_order

      t.timestamps
    end
    add_index :snippets, :manager_id
    add_index :snippets, :master_id
    add_index :snippets, :note_id
  end
end

class CreateSnippets < ActiveRecord::Migration[5.0]
  def change
    create_table :snippets do |t|
      t.integer :manager_id
      t.string :category, default: 'text'
      t.text :description
      t.string :source_type, default: 'direct'
      t.integer :source_id

      t.timestamps
    end
    add_index :snippets, :manager_id
  end
end

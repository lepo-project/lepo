class CreateTerms < ActiveRecord::Migration[5.0]
  def change
    create_table :terms do |t|
      t.string :sourced_id
      t.string :title
      t.date :start_at
      t.date :end_at

      t.timestamps null: false
    end
    add_index :terms, :sourced_id, unique: true
    add_index :terms, :title, unique: true
  end
end

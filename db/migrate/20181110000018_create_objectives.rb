class CreateObjectives < ActiveRecord::Migration[5.0]
  def change
    create_table :objectives do |t|
      t.integer :content_id
      t.string :title
      t.text :criterion
      t.integer :allocation

      t.timestamps
    end
    add_index :objectives, :content_id
  end
end

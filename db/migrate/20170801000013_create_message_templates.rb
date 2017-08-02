class CreateMessageTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :message_templates do |t|
      t.integer :manager_id
      t.integer :content_id
      t.integer :objective_id
      t.integer :counter, default: 0
      t.string :message

      t.timestamps
    end
    add_index :message_templates, :manager_id
    add_index :message_templates, :content_id
    add_index :message_templates, :objective_id
  end
end

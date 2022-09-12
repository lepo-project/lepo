class CreateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :logs do |t|
      t.integer :user_id
      t.string :controller
      t.string :action
      t.json :params
      t.string :src_ip
      t.string :user_agent

      t.timestamps
    end
    add_index :logs, :user_id
    add_index :logs, :controller
    add_index :logs, :action
  end
end

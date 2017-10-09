class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.integer :manager_id
      t.string :title
      t.string :registration_id

      t.timestamps null: false
    end
    add_index :devices, :manager_id
    add_index :devices, :registration_id, unique: true
  end
end

class CreateSignins < ActiveRecord::Migration[5.0]
  def change
    create_table :signins do |t|
      t.integer :user_id
      t.string :src_ip

      t.timestamps
    end
    add_index :signins, :user_id
  end
end

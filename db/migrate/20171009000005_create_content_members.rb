class CreateContentMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :content_members do |t|
      t.integer :content_id
      t.integer :user_id
      t.string :role

      t.timestamps
    end
    add_index :content_members, %i[user_id content_id], unique: true
  end
end

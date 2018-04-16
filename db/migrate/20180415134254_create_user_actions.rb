class CreateUserActions < ActiveRecord::Migration[5.0]
  def change
    create_table :user_actions do |t|
      t.integer :user_id
      t.string :src_ip
      t.string :category
      t.integer :course_id
      t.integer :lesson_id
      t.integer :content_id
      t.integer :page_id
      t.integer :sticky_id
      t.integer :sticky_star_id
      t.integer :snippet_id
      t.integer :outcome_id
      t.integer :outcome_message_id

      t.timestamps
    end
    add_index :user_actions, :user_id
    add_index :user_actions, :category
  end
end

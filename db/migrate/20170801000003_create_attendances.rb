class CreateAttendances < ActiveRecord::Migration[5.0]
  def change
    create_table :attendances do |t|
      t.integer :user_id
      t.integer :lesson_id
      t.string :memo
      t.timestamps
    end
    add_index :attendances, :user_id
    add_index :attendances, :lesson_id
  end
end

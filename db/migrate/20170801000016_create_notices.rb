class CreateNotices < ActiveRecord::Migration[5.0]
  def change
    create_table :notices do |t|
      t.integer :course_id
      t.integer :manager_id
      t.string :status, default: 'open'
      t.text :message

      t.timestamps
    end
    add_index :notices, :course_id
  end
end

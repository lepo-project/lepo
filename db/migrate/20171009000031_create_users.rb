class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :signin_name
      t.string :authentication, default: 'local'
      t.string :hashed_password
      t.string :salt
      t.string :token
      t.string :role, default: 'user'
      t.string :family_name
      t.string :given_name
      t.string :phonetic_family_name
      t.string :phonetic_given_name
      t.string :folder_name
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.string :web_url
      t.text :description
      t.integer :default_note_id, default: 0
      t.datetime :last_signin_at

      t.timestamps
    end
    add_index :users, :signin_name, unique: true
    add_index :users, :token, unique: true
    add_index :users, :role
    add_index :users, :folder_name, unique: true
  end
end

class AddImageDataToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :image_data, :text, after: :folder_name
  end
end

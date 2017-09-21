class AddCategoryToNotes < ActiveRecord::Migration[5.0]
  def change
    add_column :notes, :category, :string, default: 'private', after: :overview
    add_index :notes, :category
  end
end

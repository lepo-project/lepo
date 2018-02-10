class AddCategoryToPageFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :page_files, :category, :string, default: 'file', after: :display_order
  end
end

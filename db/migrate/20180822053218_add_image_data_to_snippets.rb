class AddImageDataToSnippets < ActiveRecord::Migration[5.0]
  def change
    add_column :snippets, :image_data, :string, after: :source_id
  end
end

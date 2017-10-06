class RemoveDisplayOrderFromSnippets < ActiveRecord::Migration[5.0]
  def up
    remove_column :snippets, :display_order
  end

  def down
    add_column :snippets, :display_order, :integer
  end
end

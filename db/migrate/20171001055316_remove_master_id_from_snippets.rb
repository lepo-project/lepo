class RemoveMasterIdFromSnippets < ActiveRecord::Migration[5.0]
  def up
    remove_column :snippets, :master_id
  end

  def down
    add_column :snippets, :master_id, :integer
    add_index :snippets, :master_id
  end
end

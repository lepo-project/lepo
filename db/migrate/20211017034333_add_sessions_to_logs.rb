class AddSessionsToLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :logs, :nav_section, :string, after: :params
    add_column :logs, :nav_controller, :string, after: :nav_section
    add_column :logs, :nav_id, :integer, after: :nav_controller
    add_column :logs, :content_id, :integer, after: :nav_id
    add_column :logs, :page_num, :integer, after: :content_id
    add_column :logs, :max_page_num, :integer, after: :page_num

    add_index :logs, :nav_id
    add_index :logs, :content_id
    add_index :logs, :page_num
  end
end

class RenamePageFilesToPages < ActiveRecord::Migration[5.0]
  def change
    rename_table :page_files, :pages
  end
end

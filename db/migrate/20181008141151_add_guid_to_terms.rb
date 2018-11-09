class AddGuidToTerms < ActiveRecord::Migration[5.0]
  def change
    add_column :terms, :guid, :string, after: :id
    add_index :terms, :guid, unique: true
  end
end

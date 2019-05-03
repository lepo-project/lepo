class AddSourcedIdToEnrollments < ActiveRecord::Migration[5.0]
  def change
    add_column :enrollments, :sourced_id, :string, after: :id
    add_index :enrollments, :sourced_id, unique: true
  end
end

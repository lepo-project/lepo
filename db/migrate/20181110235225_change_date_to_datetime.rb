class ChangeDateToDatetime < ActiveRecord::Migration[5.0]
  def up
    change_column :terms, :start_at, :datetime
    change_column :terms, :end_at, :datetime
  end

  def down
    change_column :terms, :start_at, :date
    change_column :terms, :end_at, :date
  end
end

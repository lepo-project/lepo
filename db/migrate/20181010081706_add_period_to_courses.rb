class AddPeriodToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :period, :integer, default: 0, after: :weekday
  end
end

class AddWeekdayToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :weekday, :integer, default: 9, after: :overview
  end
end

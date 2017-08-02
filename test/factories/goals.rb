# == Schema Information
#
# Table name: goals
#
#  id         :integer          not null, primary key
#  course_id  :integer
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :goal do
    sequence(:course_id) { |i| i }
    sequence(:title) { |i| "Course Goal #{i}" }
  end
end

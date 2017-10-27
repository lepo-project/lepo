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

FactoryBot.define do
  factory :goal do
    association :course
    sequence(:title) { |i| "Course Goal #{i}" }
  end
end

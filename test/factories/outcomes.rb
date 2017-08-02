# == Schema Information
#
# Table name: outcomes
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  course_id  :integer
#  lesson_id  :integer
#  folder_id  :string
#  status     :string           default("draft")
#  score      :integer
#  checked    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :outcome do
    sequence(:manager_id) { |i| i }
    sequence(:course_id) { |i| i }
    sequence(:lesson_id) { |i| i }
    folder_id nil
    score 10
    checked true
  end
end

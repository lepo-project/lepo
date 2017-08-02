# == Schema Information
#
# Table name: lessons
#
#  id                  :integer          not null, primary key
#  evaluator_id        :integer
#  content_id          :integer
#  course_id           :integer
#  display_order       :integer
#  status              :string
#  attendance_start_at :datetime
#  attendance_end_at   :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

FactoryGirl.define do
  factory :lesson do
    sequence(:evaluator_id) { |i| i }
    sequence(:content_id) { |i| i }
    sequence(:course_id) { |i| i }
    sequence(:display_order) { |i| i }
    status 'open'
    attendance_start_at { Time.now }
    attendance_end_at { Time.now }
  end
end

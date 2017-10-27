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

FactoryBot.define do
  factory :lesson do
    association :evaluator, factory: :user
    association :content
    association :course
    sequence(:display_order) { |i| i }
    status 'open'
    attendance_start_at { Time.now }
    attendance_end_at { Time.now }

    factory :draft_lesson do
      status 'draft'
    end
  end
end

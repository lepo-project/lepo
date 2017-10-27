# == Schema Information
#
# Table name: outcomes
#
#  id          :integer          not null, primary key
#  manager_id  :integer
#  course_id   :integer
#  lesson_id   :integer
#  folder_name :string
#  status      :string           default("draft")
#  score       :integer
#  checked     :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :outcome do
    association :course
    association :lesson
    association :manager, factory: :user
    folder_name nil
    score 10
    checked true

    factory :submit_outcome do
      status 'submit'
    end

    factory :self_submit_outcome do
      status 'self_submit'
    end

    factory :return_outcome do
      status 'return'
    end
  end
end

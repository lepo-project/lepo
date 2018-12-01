# == Schema Information
#
# Table name: course_members
#
#  id          :integer          not null, primary key
#  course_id   :integer
#  user_id     :integer
#  role        :string
#  group_index :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :course_manager, class: CourseMember do
    association :course
    association :user
    role 'manager'

    factory :course_assistant do
      role 'assistant'
    end

    factory :course_learner do
      role 'learner'
    end
  end
end

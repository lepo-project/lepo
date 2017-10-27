# == Schema Information
#
# Table name: goals_objectives
#
#  id           :integer          not null, primary key
#  lesson_id    :integer
#  goal_id      :integer
#  objective_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :goals_objective do
    association :goal
    association :lesson
    association :objective
  end
end

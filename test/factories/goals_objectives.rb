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

FactoryGirl.define do
  factory :goals_objective do
    sequence(:goal_id) { |i| i }
    sequence(:lesson_id) { |i| i }
    sequence(:objective_id) { |i| i }
  end
end

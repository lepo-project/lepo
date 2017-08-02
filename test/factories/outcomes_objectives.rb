# == Schema Information
#
# Table name: outcomes_objectives
#
#  id               :integer          not null, primary key
#  outcome_id       :integer
#  objective_id     :integer
#  self_achievement :integer
#  eval_achievement :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryGirl.define do
  factory :outcomes_objective do
    sequence(:objective_id) { |i| i }
    sequence(:outcome_id) { |i| i }
    self_achievement 10
    eval_achievement 10
  end
end

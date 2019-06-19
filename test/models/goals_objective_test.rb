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

require 'test_helper'

class GoalsObjectiveTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid goal_objective data
  test 'a goals_objective with valid data is valid' do
    assert build(:goals_objective).valid?
  end

  # validates :goal_id, presence: true
  test 'a goals_objective without goal_id is invalid' do
    assert_invalid build(:goals_objective, goal_id: ''), :goal_id
    assert_invalid build(:goals_objective, goal_id: nil), :goal_id
  end

  # validates :lesson_id, presence: true
  test 'a goals_objective without lesson_id is invalid' do
    assert_invalid build(:goals_objective, lesson_id: ''), :lesson_id
    assert_invalid build(:goals_objective, lesson_id: nil), :lesson_id
  end

  # validates :objective_id, presence: true
  test 'a goals_objective without objective_id is invalid' do
    assert_invalid build(:goals_objective, objective_id: ''), :objective_id
    assert_invalid build(:goals_objective, objective_id: nil), :objective_id
  end

  # validates :objective_id, uniqueness: { scope: :goal_id }
  test 'some goals_objectives with same objective_id and goal_id are invalid' do
    goals_objective = create(:goals_objective)
    assert_invalid build(:goals_objective, objective_id: goals_objective.objective_id, goal_id: goals_objective.goal_id), :objective_id
  end
end

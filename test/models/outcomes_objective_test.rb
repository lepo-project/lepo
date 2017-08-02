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

require 'test_helper'

class OutcomesObjectiveTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid outcome_objective data
  test 'a outcomes_objective with valid data is valid' do
    assert build(:outcomes_objective).valid?
  end

  # test for validates_presence_of :objective_id
  test 'a outcomes_objective without objective_id is invalid' do
    assert_invalid build(:outcomes_objective, objective_id: ''), :objective_id
    assert_invalid build(:outcomes_objective, objective_id: nil), :objective_id
  end

  # test for validates_presence_of :outcome_id
  test 'a outcomes_objective without outcome_id is invalid' do
    assert_invalid build(:outcomes_objective, outcome_id: ''), :outcome_id
    assert_invalid build(:outcomes_objective, outcome_id: nil), :outcome_id
  end

  # test for validates_uniqueness_of :outcome_id, scope: [:objective_id]
  test 'some outcomes_objectives with same outcome_id and objective_id are invalid' do
    outcomes_objective = create(:outcomes_objective)
    assert_invalid build(:outcomes_objective, outcome_id: outcomes_objective.outcome_id, objective_id: outcomes_objective.objective_id), :outcome_id
  end
end

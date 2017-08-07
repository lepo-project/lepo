# == Schema Information
#
# Table name: outcome_messages
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  outcome_id :integer
#  message    :text
#  score      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class OutcomeMessageTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid outcome_message data
  test 'a outcome_message with valid data is valid' do
    assert build(:outcome_message).valid?
  end

  # test for validates_presence_of :manager_id
  test 'a outcome_message without manager_id is invalid' do
    assert_invalid build(:outcome_message, manager_id: ''), :manager_id
    assert_invalid build(:outcome_message, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :outcome_id
  test 'a outcome_message without outcome_id is invalid' do
    assert_invalid build(:outcome_message, outcome_id: ''), :outcome_id
    assert_invalid build(:outcome_message, outcome_id: nil), :outcome_id
  end

  # test for validates_inclusion_of :score, in: (0..10).to_a, allow_nil: true
  test 'a outcome_message with score that is not included in (0..10).to_a is invalid' do
    assert build(:outcome_message, score: nil).valid?
    assert_invalid build(:outcome_message, score: -1), :score
    assert_invalid build(:outcome_message, score: 11), :score
  end
end

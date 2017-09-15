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

require 'test_helper'

class OutcomeTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid outcome data
  test 'a outcome with valid data is valid' do
    assert build(:outcome).valid?
    assert build(:submit_outcome).valid?
    assert build(:self_submit_outcome).valid?
    assert build(:return_outcome).valid?
  end

  # test for validates_presence_of :course_id
  test 'a outcome without course_id is invalid' do
    assert_invalid build(:outcome, course_id: ''), :course_id
    assert_invalid build(:outcome, course_id: nil), :course_id
  end

  # test for validates_presence_of :lesson_id
  test 'a outcome without lesson_id is invalid' do
    assert_invalid build(:outcome, lesson_id: ''), :lesson_id
    assert_invalid build(:outcome, lesson_id: nil), :lesson_id
  end

  # test for validates_presence_of :manager_id
  test 'a outcome without manager_id is invalid' do
    assert_invalid build(:outcome, manager_id: ''), :manager_id
    assert_invalid build(:outcome, manager_id: nil), :manager_id
  end

  # test for validates_uniqueness_of :lesson_id, scope: [:manager_id]
  test 'some outcome with same folder_name and manager_id are invalid' do
    outcome = create(:outcome)
    assert_invalid build(:outcome, lesson_id: outcome.lesson_id, manager_id: outcome.manager_id), :lesson_id
  end

  # test for validates_inclusion_of :score, in: (0..10).to_a, allow_nil: true
  test 'a outcome with score that is not included in (0..10).to_a is invalid' do
    assert build(:outcome, score: nil).valid?
    assert_invalid build(:outcome, score: -1), :score
    assert_invalid build(:outcome, score: 11), :score
  end

  # test for validates_inclusion_of :status, in: %w[draft submit self_submit return]
  test 'a outcome with status that is not included in [draft submit self_submit return] is invalid' do
    assert_invalid build(:outcome, status: ''), :status
    assert_invalid build(:outcome, status: nil), :status
  end
end

# == Schema Information
#
# Table name: outcomes
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  course_id  :integer
#  lesson_id  :integer
#  folder_id  :string
#  status     :string           default("draft")
#  score      :integer
#  checked    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class OutcomeTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid outcome data
  test 'a outcome with valid data is valid' do
    assert build(:outcome).valid?
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

  # test for validates_presence_of :status
  test 'a outcome without status is invalid' do
    assert_invalid build(:outcome, status: ''), :status
    assert_invalid build(:outcome, status: nil), :status
  end

  # test for validates_uniqueness_of :lesson_id, scope: [:manager_id]
  test 'some outcome with same folder_id and manager_id are invalid' do
    outcome = create(:outcome)
    assert_invalid build(:outcome, lesson_id: outcome.lesson_id, manager_id: outcome.manager_id), :lesson_id
  end
end

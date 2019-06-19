# == Schema Information
#
# Table name: enrollments
#
#  id          :integer          not null, primary key
#  course_id   :integer
#  user_id     :integer
#  role        :string
#  group_index :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sourced_id  :string
#

require 'test_helper'

class EnrollmentTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid enrollment data
  test 'a enrollment with valid data is valid' do
    assert build(:course_manager).valid?
    assert build(:course_assistant).valid?
    assert build(:course_learner).valid?
  end

  # validates :course_id, presence: true
  test 'a enrollment without course_id is invalid' do
    assert_invalid build(:course_manager, course_id: ''), :course_id
    assert_invalid build(:course_manager, course_id: nil), :course_id
  end

  # validates :course_id, uniqueness: { scope: :user_id }
  test 'some enrollments with same course_id and user_id are invalid' do
    enrollment = create(:course_manager)
    assert_invalid build(:course_manager, course_id: enrollment.course_id, user_id: enrollment.user_id), :course_id
  end

  # validates :group_index, inclusion: { in: (0...COURSE_GROUP_MAX_SIZE).to_a }
  test 'a enrollment with group_index that is not included in (0...COURSE_GROUP_MAX_SIZE).to_a is invalid' do
    assert_invalid build(:course_manager, group_index: ''), :group_index
    assert_invalid build(:course_manager, group_index: nil), :group_index
    assert_invalid build(:course_manager, group_index: -1), :group_index
    assert_invalid build(:course_manager, group_index: COURSE_GROUP_MAX_SIZE), :group_index
  end

  # validates :role, inclusion: { in: %w[manager assistant learner] }
  test 'a enrollment with role that is not included in [manager assistant learner] is invalid' do
    assert_invalid build(:course_manager, role: ''), :role
    assert_invalid build(:course_manager, role: nil), :role
  end

  # validates :user_id, presence: true
  test 'a enrollment without user_id is invalid' do
    assert_invalid build(:course_manager, user_id: ''), :user_id
    assert_invalid build(:course_manager, user_id: nil), :user_id
  end
end

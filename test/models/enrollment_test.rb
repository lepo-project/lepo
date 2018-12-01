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

require 'test_helper'

class CourseMemberTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid course_member data
  test 'a course_member with valid data is valid' do
    assert build(:course_manager).valid?
    assert build(:course_assistant).valid?
    assert build(:course_learner).valid?
  end

  # test for validates_presence_of :course_id
  test 'a course_member without course_id is invalid' do
    assert_invalid build(:course_manager, course_id: ''), :course_id
    assert_invalid build(:course_manager, course_id: nil), :course_id
  end

  # test for validates_presence_of :user_id
  test 'a course_member without user_id is invalid' do
    assert_invalid build(:course_manager, user_id: ''), :user_id
    assert_invalid build(:course_manager, user_id: nil), :user_id
  end

  # test for validates_uniqueness_of :course_id, scope: [:user_id]
  test 'some course_members with same course_id and user_id are invalid' do
    course_member = create(:course_manager)
    assert_invalid build(:course_manager, course_id: course_member.course_id, user_id: course_member.user_id), :course_id
  end

  # test for validates_inclusion_of :group_index, in: (0...COURSE_GROUP_MAX_SIZE).to_a
  test 'a course_member with group_index that is not included in (0...COURSE_GROUP_MAX_SIZE).to_a is invalid' do
    assert_invalid build(:course_manager, group_index: ''), :group_index
    assert_invalid build(:course_manager, group_index: nil), :group_index
    assert_invalid build(:course_manager, group_index: -1), :group_index
    assert_invalid build(:course_manager, group_index: COURSE_GROUP_MAX_SIZE), :group_index
  end

  # test for validates_inclusion_of :role, in: %w[manager assistant learner]
  test 'a course_member with role that is not included in [manager assistant learner] is invalid' do
    assert_invalid build(:course_manager, role: ''), :role
    assert_invalid build(:course_manager, role: nil), :role
  end
end

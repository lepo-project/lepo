# == Schema Information
#
# Table name: course_members
#
#  id         :integer          not null, primary key
#  course_id  :integer
#  user_id    :integer
#  role       :string
#  group_id   :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class CourseMemberTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid course_member data
  test 'a course_member with valid data is valid' do
    assert build(:course_member).valid?
  end

  # test for validates_presence_of :course_id
  test 'a course_member without course_id is invalid' do
    assert_invalid build(:course_member, course_id: ''), :course_id
    assert_invalid build(:course_member, course_id: nil), :course_id
  end

  # test for validates_presence_of :user_id
  test 'a course_member without user_id is invalid' do
    assert_invalid build(:course_member, user_id: ''), :user_id
    assert_invalid build(:course_member, user_id: nil), :user_id
  end

  # test for validates_presence_of :role
  test 'a course_member without role is invalid' do
    assert_invalid build(:course_member, role: ''), :role
    assert_invalid build(:course_member, role: nil), :role
  end

  # test for validates_uniqueness_of :course_id, scope: [:user_id]
  test 'some course_members with same course_id and user_id are invalid' do
    course_member = create(:course_member)
    assert_invalid build(:course_member, course_id: course_member.course_id, user_id: course_member.user_id), :course_id
  end
end

# == Schema Information
#
# Table name: courses
#
#  id           :integer          not null, primary key
#  term_id      :integer
#  title        :string
#  overview     :text
#  status       :string           default("draft")
#  groups_count :integer          default(1)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  image_data   :text
#  guid         :string
#  weekday      :integer          default(9)
#  period       :integer          default(0)
#  enabled      :boolean          default(TRUE)
#

require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid course data
  test 'a course with valid data is valid' do
    assert build(:course).valid?
    assert build(:open_course).valid?
    assert build(:archived_course).valid?
  end

  # test for validates_presence_of :overview
  test 'a course without overview is invalid' do
    assert_invalid build(:course, overview: ''), :overview
    assert_invalid build(:course, overview: nil), :overview
  end

  # test for validates_presence_of :term_id
  test 'a course without term_id is invalid' do
    assert_invalid build(:course, term_id: ''), :term_id
    assert_invalid build(:course, term_id: nil), :term_id
  end

  # test for validates_presence_of :title
  test 'a course without title is invalid' do
    assert_invalid build(:course, title: ''), :title
    assert_invalid build(:course, title: nil), :title
  end

  # test for validates_inclusion_of :groups_count, in: (1..COURSE_GROUP_MAX_SIZE).to_a
  test 'a course with group_count that is not included in (1..COURSE_GROUP_MAX_SIZE).to_a is invalid' do
    assert_invalid build(:course, groups_count: ''), :groups_count
    assert_invalid build(:course, groups_count: nil), :groups_count
    assert_invalid build(:course, groups_count: 0), :groups_count
    assert_invalid build(:course, groups_count: COURSE_GROUP_MAX_SIZE + 1), :groups_count
  end

  # test for validates_inclusion_of :status, in: %w[draft open archived]
  test 'a course with status that is not included in [draft open archived] is invalid' do
    assert_invalid build(:course, status: ''), :status
    assert_invalid build(:course, status: nil), :status
  end

  # test for validates :enabled, inclusion: { in: [true, false] }
  test 'a course with enabled that is not included in [true, false] is invalid' do
    assert_invalid build(:course, enabled: nil), :enabled
  end

  # test for validates_inclusion_of :period, in: (0..COURSE_PERIOD_MAX_SIZE).to_a
  test 'a course with period that is not included in 0..COURSE_PERIOD_MAX_SIZE is invalid' do
    assert_invalid build(:course, period: COURSE_PERIOD_MAX_SIZE + 1), :period
    assert_invalid build(:course, period: nil), :period
  end

  # test for validates_inclusion_of :weekday, in: [1, 2, 3, 4, 5, 6, 7, 9]
  test 'a course with weekday that is not included in [1, 2, 3, 4, 5, 6, 7, 9] is invalid' do
    assert_invalid build(:course, weekday: 0), :weekday
    assert_invalid build(:course, weekday: 8), :weekday
    assert_invalid build(:course, weekday: nil), :weekday
  end

  # test for validates_uniqueness_of :guid, allow_nil: true
  test 'some courses with same guid are invalid' do
    course = create(:course)
    assert_invalid build(:course, guid: course.guid), :guid
  end
end

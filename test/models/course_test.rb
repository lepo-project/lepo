# == Schema Information
#
# Table name: courses
#
#  id           :integer          not null, primary key
#  enabled      :boolean          default(TRUE)
#  sourced_id   :string
#  term_id      :integer
#  image_data   :text
#  title        :string
#  overview     :text
#  weekday      :integer          default(9)
#  period       :integer          default(0)
#  status       :string           default("draft")
#  groups_count :integer          default(1)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
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

  # validates :enabled, inclusion: { in: [true, false] }
  test 'a course with enabled that is not included in [true, false] is invalid' do
    assert_invalid build(:course, enabled: nil), :enabled
  end

  # validates :groups_count, inclusion: { in: (1..COURSE_GROUP_MAX_SIZE).to_a }
  test 'a course with group_count that is not included in (1..COURSE_GROUP_MAX_SIZE).to_a is invalid' do
    assert_invalid build(:course, groups_count: ''), :groups_count
    assert_invalid build(:course, groups_count: nil), :groups_count
    assert_invalid build(:course, groups_count: 0), :groups_count
    assert_invalid build(:course, groups_count: COURSE_GROUP_MAX_SIZE + 1), :groups_count
  end

  # validates :overview, presence: true
  test 'a course without overview is invalid' do
    assert_invalid build(:course, overview: ''), :overview
    assert_invalid build(:course, overview: nil), :overview
  end

  # validates :period, inclusion: { in: (0..COURSE_PERIOD_MAX_SIZE).to_a }
  test 'a course with period that is not included in 0..COURSE_PERIOD_MAX_SIZE is invalid' do
    assert_invalid build(:course, period: COURSE_PERIOD_MAX_SIZE + 1), :period
    assert_invalid build(:course, period: nil), :period
  end

  # validates :sourced_id, uniqueness: true, allow_nil: true
  test 'some courses with same sourced_id are invalid' do
    course = create(:course)
    assert_invalid build(:course, sourced_id: course.sourced_id), :sourced_id
  end

  # validates :status, inclusion: { in: %w[draft open archived] }
  test 'a course with status that is not included in [draft open archived] is invalid' do
    assert_invalid build(:course, status: ''), :status
    assert_invalid build(:course, status: nil), :status
  end

  # validates :term_id, presence: true
  test 'a course without term_id is invalid' do
    assert_invalid build(:course, term_id: ''), :term_id
    assert_invalid build(:course, term_id: nil), :term_id
  end

  # validates :title, presence: true
  test 'a course without title is invalid' do
    assert_invalid build(:course, title: ''), :title
    assert_invalid build(:course, title: nil), :title
  end

  # validates :weekday, inclusion: { in: [1, 2, 3, 4, 5, 6, 7, 9] }
  test 'a course with weekday that is not included in [1, 2, 3, 4, 5, 6, 7, 9] is invalid' do
    assert_invalid build(:course, weekday: 0), :weekday
    assert_invalid build(:course, weekday: 8), :weekday
    assert_invalid build(:course, weekday: nil), :weekday
  end

  # validate :term_and_sync_consistency
  # FIXME
end

# == Schema Information
#
# Table name: lessons
#
#  id                  :integer          not null, primary key
#  evaluator_id        :integer
#  content_id          :integer
#  course_id           :integer
#  display_order       :integer
#  status              :string
#  attendance_start_at :datetime
#  attendance_end_at   :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class LessonTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid lesson data
  test 'a lesson with valid data is valid' do
    assert build(:lesson).valid?
    assert build(:draft_lesson).valid?
  end

  # validates :content_id, presence: true
  test 'a lesson without content_id is invalid' do
    assert_invalid build(:lesson, content_id: ''), :content_id
    assert_invalid build(:lesson, content_id: nil), :content_id
  end

  # validates :content_id, uniqueness: { scope: :course_id }
  test 'some lessons with same content_id and course_id are invalid' do
    lesson = create(:lesson)
    assert_invalid build(:lesson, content_id: lesson.content_id, course_id: lesson.course_id), :content_id
  end

  # validates :course_id, presence: true
  test 'a lesson without course_id is invalid' do
    assert_invalid build(:lesson, course_id: ''), :course_id
    assert_invalid build(:lesson, course_id: nil), :course_id
  end

  # validates :display_order, presence: true
  test 'a lesson without display_order is invalid' do
    assert_invalid build(:lesson, display_order: ''), :display_order
    assert_invalid build(:lesson, display_order: nil), :display_order
  end

  # validates :evaluator_id, presence: true
  test 'a lesson without evaluator_id is invalid' do
    assert_invalid build(:lesson, evaluator_id: ''), :evaluator_id
    assert_invalid build(:lesson, evaluator_id: nil), :evaluator_id
  end

  # validates :status, inclusion: { in: %w[draft open] }
  test 'a lesson with status that is not included in [draft open] is invalid' do
    assert_invalid build(:lesson, status: ''), :status
    assert_invalid build(:lesson, status: nil), :status
  end
end

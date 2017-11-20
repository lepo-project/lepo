# == Schema Information
#
# Table name: notes
#
#  id                 :integer          not null, primary key
#  manager_id         :integer
#  course_id          :integer          default(0)
#  original_ws_id     :integer          default(0)
#  title              :string
#  overview           :text
#  status             :string           default("draft")
#  stars_count        :integer          default(0)
#  peer_reviews_count :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  category           :string           default("private")
#

require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid note data
  test 'a note with valid data is valid' do
    assert build(:note).valid?
    assert build(:lesson_note).valid?
    assert build(:original_draft_work_sheet).valid?
    assert build(:original_review_work_sheet).valid?
    assert build(:original_open_work_sheet).valid?
  end

  # test for validates_presence_of :manager_id
  test 'a note without manager_id is invalid' do
    assert_invalid build(:note, manager_id: ''), :manager_id
    assert_invalid build(:note, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :title
  test 'a note without title is invalid' do
    assert_invalid build(:note, title: ''), :title
    assert_invalid build(:note, title: nil), :title
  end

  # test for validates_inclusion_of :peer_reviews_count, in: (0..NOTE_PEER_REVIEW_MAX_SIZE).to_a
  test 'a note with peer_reviews_count that is not included in (0..NOTE_PEER_REVIEW_MAX_SIZE).to_a is invalid' do
    assert_invalid build(:note, peer_reviews_count: ''), :peer_reviews_count
    assert_invalid build(:note, peer_reviews_count: nil), :peer_reviews_count
    assert_invalid build(:note, peer_reviews_count: -1), :peer_reviews_count
    assert_invalid build(:note, peer_reviews_count: NOTE_PEER_REVIEW_MAX_SIZE + 1), :peer_reviews_count
  end

  # test for validates_inclusion_of :category, in: %w[private lesson work]
  test 'a note with category that is not included in [private lesson work] is invalid' do
    assert_invalid build(:note, category: ''), :category
    assert_invalid build(:note, category: nil), :category
  end

  # test for validates_inclusion_of :status, in: %w[draft archived], if: "category == 'private'"
  test 'a private note with status that is not included in [draft archived] is invalid' do
    assert_invalid build(:note, status: ''), :status
    assert_invalid build(:note, status: nil), :status
  end

  # test for validates_inclusion_of :status, in: %w[associated_course], if: "category == 'lesson'"
  test 'a lesson note with status that is not included in [associated_course] is invalid' do
    assert_invalid build(:lesson_note, status: ''), :status
    assert_invalid build(:lesson_note, status: nil), :status
  end

  # test for validates_inclusion_of :status, in: %w[draft review open archived original_ws], if: "category == 'work'"
  test 'a work sheet note with status that is not included in [draft review open archived original_ws] is invalid' do
    assert_invalid build(:original_draft_work_sheet, status: ''), :status
    assert_invalid build(:original_draft_work_sheet, status: nil), :status
  end

  # test for validates_numericality_of :course_id, allow_nil: false, equal_to: 0, if: "category == 'private'"
  test 'a private note with course_id that is not 0 is invalid' do
    assert_invalid build(:note, course_id: 1), :course_id
    assert_invalid build(:note, course_id: -1), :course_id
  end

  # test for validates_numericality_of :course_id, allow_nil: false, greater_than: 0, if: "category != 'private'"
  test 'a lesson & work sheet note with course_id that is less than or equal to 0 is invalid' do
    assert_invalid build(:lesson_note, course_id: 0), :course_id
    assert_invalid build(:original_draft_work_sheet, course_id: 0), :course_id
  end

  # test for validates_numericality_of :original_ws_id, allow_nil: false, greater_than_or_equal_to: 0, if: "category == 'work'"
  test 'a work sheet note with original_ws_id that is less than 0 is invalid' do
    assert_invalid build(:original_draft_work_sheet, original_ws_id: -1), :original_ws_id
  end

  # test for validates_numericality_of :original_ws_id, allow_nil: false, equal_to: 0, if: "category != 'work'"
  test 'a private & lesson note with original_ws_id that is not 0 is invalid' do
    assert_invalid build(:note, original_ws_id: 1), :original_ws_id
    assert_invalid build(:note, original_ws_id: -1), :original_ws_id
    assert_invalid build(:lesson_note, original_ws_id: 1), :original_ws_id
    assert_invalid build(:lesson_note, original_ws_id: -1), :original_ws_id
  end

  # test for validates_uniqueness_of :manager_id, scope: [:course_id], if: "category == 'lesson'"
  # test 'some lesson notes with same manager_id and course_id are invalid' do
  #   lesson_note = create(:lesson_note)
  #   assert_invalid build(:lesson_note, manager_id: lesson_note.manager_id, course_id: lesson_note.course_id), :manager_id
  # end
end

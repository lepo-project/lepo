# == Schema Information
#
# Table name: notes
#
#  id                 :integer          not null, primary key
#  manager_id         :integer
#  course_id          :integer
#  master_id          :integer          default(0)
#  title              :string
#  overview           :text
#  status             :string           default("private")
#  stars_count        :integer          default(0)
#  peer_reviews_count :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid note data
  test 'a note with valid data is valid' do
    assert build(:note).valid?
    assert build(:course_note).valid?
    assert build(:master_draft_note).valid?
    assert build(:master_review_note).valid?
    assert build(:master_open_note).valid?
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

  # test for validates_inclusion_of :status, in: %w[private course master_draft master_review master_open]
  test 'a note with status that is not included in [private course master_draft master_review master_open] is invalid' do
    assert_invalid build(:note, status: ''), :status
    assert_invalid build(:note, status: nil), :status
  end
end

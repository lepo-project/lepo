# == Schema Information
#
# Table name: note_stars
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  note_id    :integer
#  stared     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class NoteStarTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid note_star data
  test 'a note_star with valid data is valid' do
    assert build(:note_star).valid?
  end

  # test for validates_presence_of :manager_id
  test 'a note_star without manager_id is invalid' do
    assert_invalid build(:note_star, manager_id: ''), :manager_id
    assert_invalid build(:note_star, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :note_id
  test 'a note_star without note_id is invalid' do
    assert_invalid build(:note_star, note_id: ''), :note_id
    assert_invalid build(:note_star, note_id: nil), :note_id
  end

  # test for validates_uniqueness_of :manager_id, scope: [:note_id]
  test 'some note_stars with same manager_id and note_id are invalid' do
    note_star = create(:note_star)
    assert_invalid build(:note_star, manager_id: note_star.manager_id, note_id: note_star.note_id), :manager_id
  end
end

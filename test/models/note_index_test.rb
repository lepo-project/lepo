# == Schema Information
#
# Table name: note_indices
#
#  id            :integer          not null, primary key
#  note_id       :integer
#  snippet_id    :integer
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class NoteIndexTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid note_index data
  test 'a note_index with valid data is valid' do
    assert build(:note_index).valid?
  end

  # test for validates_presence_of :display_order
  test 'a note_index without display_order is invalid' do
    assert_invalid build(:note_index, display_order: ''), :display_order
    assert_invalid build(:note_index, display_order: nil), :display_order
  end

  # test for validates_presence_of :note_id
  test 'a note_index without note_id is invalid' do
    assert_invalid build(:note_index, note_id: ''), :note_id
    assert_invalid build(:note_index, note_id: nil), :note_id
  end

  # test for validates_presence_of :snippet_id
  test 'a note_index without snippet_id is invalid' do
    assert_invalid build(:note_index, snippet_id: ''), :snippet_id
    assert_invalid build(:note_index, snippet_id: nil), :snippet_id
  end

  # test for validates_uniqueness_of :display_order, scope: [:note_id]
  test 'some note_indices with same display_order and note_id are invalid' do
    note_index = create(:note_index)
    assert_invalid build(:note_index, display_order: note_index.display_order, note_id: note_index.note_id), :display_order
  end

  # test for validates_uniqueness_of :snippet_id, scope: [:note_id]
  test 'some note_indices with same snippet_id and note_id are invalid' do
    note_index = create(:note_index)
    assert_invalid build(:note_index, snippet_id: note_index.snippet_id, note_id: note_index.note_id), :snippet_id
  end
end

# == Schema Information
#
# Table name: note_indices
#
#  id            :integer          not null, primary key
#  note_id       :integer
#  item_id       :integer
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  item_type     :string           default("Snippet")
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

  # test for validates_presence_of :item_id
  test 'a note_index without item_id is invalid' do
    assert_invalid build(:note_index, item_id: ''), :item_id
    assert_invalid build(:note_index, item_id: nil), :item_id
  end

  # test for validates_inclusion_of :item_type, in: %w[Snippet Content]
  test 'a note_index with item_type that is not incluede in [Snippet Content] is invalid' do
    assert_invalid build(:note_index, item_type: ''), :item_type
    assert_invalid build(:note_index, item_type: nil), :item_type
  end
end

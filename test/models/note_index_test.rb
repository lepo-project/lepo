# == Schema Information
#
# Table name: note_indices
#
#  id            :integer          not null, primary key
#  note_id       :integer
#  item_id       :integer
#  item_type     :string           default("Snippet")
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

  # validates :display_order, presence: true
  test 'a note_index without display_order is invalid' do
    assert_invalid build(:note_index, display_order: ''), :display_order
    assert_invalid build(:note_index, display_order: nil), :display_order
  end

  # validates :item_id, presence: true
  test 'a note_index without item_id is invalid' do
    assert_invalid build(:note_index, item_id: ''), :item_id
    assert_invalid build(:note_index, item_id: nil), :item_id
  end

  # validates :item_id, uniqueness: { scope: %i[item_type note_id] }
  test 'some note_indices with same item_id and item_type and note_id are invalid' do
    note_index = create(:note_index)
    assert_invalid build(:note_index, item_id: note_index.item_id, item_type: note_index.item_type, note_id: note_index.note_id), :item_id
  end

  # validates :item_type, inclusion: { in: %w[Content Snippet Sticky] }
  test 'a note_index with item_type that is not incluede in [Snippet Content] is invalid' do
    assert_invalid build(:note_index, item_type: ''), :item_type
    assert_invalid build(:note_index, item_type: nil), :item_type
  end

  # validates :note_id, presence: true
  test 'a note_index without note_id is invalid' do
    assert_invalid build(:note_index, note_id: ''), :note_id
    assert_invalid build(:note_index, note_id: nil), :note_id
  end
end

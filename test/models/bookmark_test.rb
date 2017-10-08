# == Schema Information
#
# Table name: bookmarks
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  display_order :integer
#  display_title :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  target_id     :integer
#  target_type   :string           default("web")
#

require 'test_helper'

class BookmarkTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid bookmark data
  test 'a bookmark with valid data is valid' do
    assert build(:bookmark).valid?
  end

  # test for validates_presence_of :display_order
  test 'a bookmark without display_order is invalid' do
    assert_invalid build(:bookmark, display_order: ''), :display_order
    assert_invalid build(:bookmark, display_order: nil), :display_order
  end

  # test for validates_presence_of :display_title
  test 'a bookmark without display_title is invalid' do
    assert_invalid build(:bookmark, display_title: ''), :display_title
    assert_invalid build(:bookmark, display_title: nil), :display_title
  end

  # test for validates_presence_of :manager_id
  test 'a bookmark without manager_id is invalid' do
    assert_invalid build(:bookmark, manager_id: ''), :manager_id
    assert_invalid build(:bookmark, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :target_id
  test 'a bookmark without target_id is invalid' do
    assert_invalid build(:bookmark, target_id: ''), :target_id
    assert_invalid build(:bookmark, target_id: nil), :target_id
  end

  # test for validates_inclusion_of :target_type, in: %w[web]
  test 'a bookmark with target_type that is not incluede in [web] is invalid' do
    assert_invalid build(:bookmark, target_type: ''), :target_type
    assert_invalid build(:bookmark, target_type: nil), :target_type
  end

  # test for validates_uniqueness_of :display_title, scope: [:manager_id]
  test 'some bookmarks with same display_title and manager_id are invalid' do
    bookmark = create(:bookmark)
    assert_invalid build(:bookmark, display_title: bookmark.display_title, manager_id: bookmark.manager_id), :display_title
  end
end

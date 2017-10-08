# == Schema Information
#
# Table name: bookmarks
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  display_order :integer
#  url           :text
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
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

  # test for validates_presence_of :manager_id
  test 'a bookmark without manager_id is invalid' do
    assert_invalid build(:bookmark, manager_id: ''), :manager_id
    assert_invalid build(:bookmark, manager_id: nil), :manager_id
  end

  # test for validates_presence_of :title
  test 'a bookmark without title is invalid' do
    assert_invalid build(:bookmark, title: ''), :title
    assert_invalid build(:bookmark, title: nil), :title
  end

  # test for validates_presence_of :url
  test 'a bookmark without url is invalid' do
    assert_invalid build(:bookmark, url: ''), :url
    assert_invalid build(:bookmark, url: nil), :url
  end

  # test for validates_uniqueness_of :title, scope: [:manager_id]
  test 'some bookmarks with same title and manager_id are invalid' do
    bookmark = create(:bookmark)
    assert_invalid build(:bookmark, title: bookmark.title, manager_id: bookmark.manager_id), :title
  end

  # test for  validates :url, format: URI.regexp(%w[http https])
  test 'a bookmark with incorrect url is invalid' do
    assert_invalid build(:bookmark, url: 'abc'), :url
  end
end

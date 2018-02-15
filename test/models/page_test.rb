# == Schema Information
#
# Table name: pages
#
#  id                  :integer          not null, primary key
#  content_id          :integer
#  display_order       :integer
#  category            :string           default("file")
#  upload_file_name    :string
#  upload_content_type :string
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class PageTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid page/cover/assignment data
  test 'a page with valid data is valid' do
    assert build(:page).valid?
    assert build(:cover_page).valid?
    assert build(:assignment_page).valid?
  end

  # test validates_presence_of :content_id
  test 'a page without content_id is invalid' do
    assert_invalid build(:page, content_id: ''), :content_id
    assert_invalid build(:page, content_id: nil), :content_id
    assert_invalid build(:cover_page, content_id: ''), :content_id
    assert_invalid build(:cover_page, content_id: nil), :content_id
    assert_invalid build(:assignment_page, content_id: ''), :content_id
    assert_invalid build(:assignment_page, content_id: nil), :content_id
  end

  # test validates_presence_of :upload_file_name, if: "category == 'file'"
  test 'a file page without upload_file_name is invalid' do
    assert_invalid build(:page, upload_file_name: ''), :upload_file_name
    assert_invalid build(:page, upload_file_name: nil), :upload_file_name
  end

  # test for validates_inclusion_of :category, in: %w[file cover assignment]
  test 'a page with category that is not included in [file cover assignment] is invalid ' do
    assert_invalid build(:page, category: ''), :category
    assert_invalid build(:page, category: nil), :category
  end

  # test for validates_uniqueness_of :category, scope: [:content_id], if: "category == 'cover'"
  test 'some cover pages with same content_id are invalid' do
    cover_page = create(:cover_page)
    assert_invalid build(:cover_page, content_id: cover_page.content_id), :category
  end

  # test for validates_uniqueness_of :category, scope: [:content_id], if: "category == 'assignment'"
  test 'some assignment_pages with same content_id are invalid' do
    assignment_page = create(:assignment_page)
    assert_invalid build(:assignment_page, content_id: assignment_page.content_id), :category
  end

  # test for validates_uniqueness_of :upload_file_name, scope: [:content_id], if: "category == 'file'"
  test 'some file pages with same upload_file_name and content_id are invalid' do
    file_page = create(:page)
    assert_invalid build(:page, upload_file_name: file_page.upload_file_name, content_id: file_page.content_id), :upload_file_name
  end

  # test for validates_numericality_of :display_order, equal_to: 0, if: "category == 'cover'"
  test 'a cover page with display_order that is not 0 is invalid' do
    assert_invalid build(:cover_page, display_order: 1), :display_order
    assert_invalid build(:cover_page, display_order: -1), :display_order
  end
  # test for validates_numericality_of :display_order, greater_than: 0, if: "category != 'cover'"
  test 'a file/assignment page with display_order less than or equal to 0 is invalid' do
    assert_invalid build(:page, display_order: 0), :display_order
    assert_invalid build(:page, display_order: -1), :display_order
    assert_invalid build(:assignment_page, display_order: 0), :display_order
    assert_invalid build(:assignment_page, display_order: -1), :display_order
  end
end

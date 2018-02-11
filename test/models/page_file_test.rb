# == Schema Information
#
# Table name: page_files
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

class PageFileTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid page_file/cover/assignment data
  test 'a page_file/cover/assignment with valid data is valid' do
    assert build(:page_file).valid?
    assert build(:page_cover).valid?
    assert build(:page_assignment).valid?
  end

  # test validates_presence_of :content_id
  test 'a page_file/cover/assignment without content_id is invalid' do
    assert_invalid build(:page_file, content_id: ''), :content_id
    assert_invalid build(:page_file, content_id: nil), :content_id
    assert_invalid build(:page_cover, content_id: ''), :content_id
    assert_invalid build(:page_cover, content_id: nil), :content_id
    assert_invalid build(:page_assignment, content_id: ''), :content_id
    assert_invalid build(:page_assignment, content_id: nil), :content_id
  end

  # test validates_presence_of :upload_file_name, if: "category == 'file'"
  test 'a page_file without upload_file_name is invalid' do
    assert_invalid build(:page_file, upload_file_name: ''), :upload_file_name
    assert_invalid build(:page_file, upload_file_name: nil), :upload_file_name
  end

  # test for validates_inclusion_of :category, in: %w[file cover assignment]
  test 'a page_file with category that is not included in [file cover assignment] is invalid ' do
    assert_invalid build(:page_file, category: ''), :category
    assert_invalid build(:page_file, category: nil), :category
  end

  # test for validates_uniqueness_of :content_id, if: "category == 'cover'"
  test 'some page_files with same content_id with cover category are invalid' do
    page_cover = create(:page_cover)
    assert_invalid build(:page_cover, content_id: page_cover.content_id), :content_id
  end

  # test for validates_uniqueness_of :content_id, if: "category == 'assignment'"
  test 'some page_files with same content_id with assignment category are invalid' do
    page_assignment = create(:page_assignment)
    assert_invalid build(:page_assignment, content_id: page_assignment.content_id), :content_id
  end

  # test for validates_uniqueness_of :upload_file_name, scope: [:content_id], if: "category == 'file'"
  test 'some page_files with same upload_file_name and content_id are invalid' do
    page_file = create(:page_file)
    assert_invalid build(:page_file, upload_file_name: page_file.upload_file_name, content_id: page_file.content_id), :upload_file_name
  end

  # test for validates_numericality_of :display_order, equal_to: 0, if: "category == 'cover'"
  test 'a page_file with cover category with display_order that is not 0 is invalid' do
    assert_invalid build(:page_cover, display_order: 1), :display_order
    assert_invalid build(:page_cover, display_order: -1), :display_order
  end
  # test for validates_numericality_of :display_order, greater_than: 0, if: "category != 'cover'"
  test 'a page_file with file/assignment category with display_order less than or equal to 0 is invalid' do
    assert_invalid build(:page_file, display_order: 0), :display_order
    assert_invalid build(:page_file, display_order: -1), :display_order
    assert_invalid build(:page_assignment, display_order: 0), :display_order
    assert_invalid build(:page_assignment, display_order: -1), :display_order
  end
end

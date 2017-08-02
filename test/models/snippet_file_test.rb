# == Schema Information
#
# Table name: snippet_files
#
#  id                  :integer          not null, primary key
#  snippet_id          :integer
#  upload_file_name    :string
#  upload_content_type :string
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class SnippetFileTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid snippet_file data
  test 'a snippet_file with valid data is valid' do
    assert build(:snippet_file).valid?
  end

  # test for validates_presence_of :snippet_id
  test 'a snippet_file without snippet_id is invalid' do
    assert_invalid build(:snippet_file, snippet_id: ''), :snippet_id
    assert_invalid build(:snippet_file, snippet_id: nil), :snippet_id
  end

  # test for validates_presence_of :upload_file_name
  test 'a snippet_file without upload_file_name is invalid' do
    assert_invalid build(:snippet_file, upload_file_name: ''), :upload_file_name
    assert_invalid build(:snippet_file, upload_file_name: nil), :upload_file_name
  end
end

# == Schema Information
#
# Table name: asset_files
#
#  id                  :integer          not null, primary key
#  content_id          :integer
#  upload_file_name    :string
#  upload_content_type :string
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class AssetFileTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid asset_file data
  test 'an asset_file with valid data is valid' do
    assert build(:asset_file).valid?
  end

  # test for validates_presence_of :content_id
  test 'an asset_file without content_id is invalid' do
    assert_invalid build(:asset_file, content_id: ''), :content_id
    assert_invalid build(:asset_file, content_id: nil), :content_id
  end

  # test for validates_presence_of :upload_file_name
  test 'an asset_file without upload_file_name is invalid' do
    assert_invalid build(:asset_file, upload_file_name: ''), :upload_file_name
    assert_invalid build(:asset_file, upload_file_name: nil), :upload_file_name
  end
end

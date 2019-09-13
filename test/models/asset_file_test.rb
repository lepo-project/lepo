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

  # validates :content_id, presence: true
  test 'an asset_file without content_id is invalid' do
    assert_invalid build(:asset_file, content_id: ''), :content_id
    assert_invalid build(:asset_file, content_id: nil), :content_id
  end

  # validates :upload_file_name, presence: true
  test 'an asset_file without upload_file_name is invalid' do
    assert_invalid build(:asset_file, upload_file_name: ''), :upload_file_name
    assert_invalid build(:asset_file, upload_file_name: nil), :upload_file_name
  end

  # validates :upload_file_name, uniqueness: { scope: :content_id }
  test 'some asset_files with same upload_file_name and content_id are invalid' do
    asset_file = create(:asset_file)
    assert_invalid build(:asset_file, upload_file_name: asset_file.upload_file_name, content_id: asset_file.content_id), :upload_file_name
  end
end

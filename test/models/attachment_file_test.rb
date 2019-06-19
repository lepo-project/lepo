# == Schema Information
#
# Table name: attachment_files
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

class AttachmentFileTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid attachment_file data
  test 'an attachment_file with valid data is valid' do
    assert build(:attachment_file).valid?
  end

  # validates :content_id, presence: true
  test 'an attachment_file without content_id is invalid' do
    assert_invalid build(:attachment_file, content_id: ''), :content_id
    assert_invalid build(:attachment_file, content_id: nil), :content_id
  end

  # validates :upload_file_name, presence: true
  test 'an attachment_file without upload_file_name is invalid' do
    assert_invalid build(:attachment_file, upload_file_name: ''), :upload_file_name
    assert_invalid build(:attachment_file, upload_file_name: nil), :upload_file_name
  end

  # validates :upload_file_name, uniqueness: { scope: :content_id }
  test 'some attachment_files with same upload_file_name and content_id are invalid' do
    attachment_file = create(:attachment_file)
    assert_invalid build(:attachment_file, upload_file_name: attachment_file.upload_file_name, content_id: attachment_file.content_id), :upload_file_name
  end
end

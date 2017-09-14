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

class AssetFile < ApplicationRecord
  has_attached_file :upload,
                    path: ':rails_root/public/system/contents/:content_folder_name/:filename',
                    url: ':relative_url_root/system/contents/:content_folder_name/:filename'
  do_not_validate_attachment_file_type :upload
  validates_attachment_size :upload, less_than: CONTENT_MAX_FILE_SIZE.megabytes

  belongs_to :content, touch: true
  validates_presence_of :content_id
  validates_presence_of :upload_file_name
  validates_uniqueness_of :upload_file_name, scope: [:content_id]
end

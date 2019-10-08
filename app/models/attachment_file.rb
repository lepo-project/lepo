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

class AttachmentFile < ApplicationRecord
  has_attached_file :upload,
                    path: ':rails_root/public/system/contents/:content_folder_name/attachment_files/:filename',
                    url: '/system/contents/:content_folder_name/attachment_files/:filename'
  do_not_validate_attachment_file_type :upload
  validates_attachment_size :upload, less_than: CONTENT_MAX_FILE_SIZE.megabytes
  belongs_to :content, touch: true
  validates :content_id, presence: true
  validates :upload_file_name, presence: true
  validates :upload_file_name, uniqueness: { scope: :content_id }
end

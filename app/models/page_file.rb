# == Schema Information
#
# Table name: page_files
#
#  id                  :integer          not null, primary key
#  content_id          :integer
#  display_order       :integer
#  upload_file_name    :string
#  upload_content_type :string
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class PageFile < ApplicationRecord
  has_attached_file :upload,
  path: ':rails_root/public/system/contents/:content_folder_id/:filename',
  url: ':relative_url_root/system/contents/:content_folder_id/:filename'
  validates_attachment_content_type :upload, content_type: ['image/gif', 'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png', 'text/html', 'video/mp4', 'video/quicktime', 'video/x-flv']
  validates_attachment_size :upload, less_than: CONTENT_MAX_FILE_SIZE.megabytes
  belongs_to :content, touch: true
  has_many :stickies, -> { where('stickies.target_type = ?', 'page') }, foreign_key: 'target_id', dependent: :destroy
  validates_presence_of :content_id
  validates_presence_of :upload_file_name
  validates_uniqueness_of :upload_file_name, scope: [:content_id]
end

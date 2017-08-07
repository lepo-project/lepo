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

class SnippetFile < ApplicationRecord
  has_attached_file :upload,
  path: ':rails_root/public/system/users/:snippet_manager_folder_id/upload_snippets/:snippet_id/:filename',
  url: ':relative_url_root/system/users/:snippet_manager_folder_id/upload_snippets/:snippet_id/:filename'
  validates_attachment_size :upload, less_than: IMAGE_MAX_FILE_SIZE.megabytes
  validates_attachment_content_type :upload, content_type: ['image/gif', 'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png', 'application/pdf']

  belongs_to :snippet, touch: true
  validates_presence_of :snippet_id
  validates_presence_of :upload_file_name
  validates_uniqueness_of :snippet_id

  # ====================================================================
  # Public Functions
  # ====================================================================

  def file_type
    return 'pdf' if upload_content_type == 'application/pdf'
    'image'
  end
end

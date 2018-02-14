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

class Page < ApplicationRecord
  has_attached_file :upload,
  path: ':rails_root/public/system/contents/:content_folder_name/:filename',
  url: ':relative_url_root/system/contents/:content_folder_name/:filename'
  validates_attachment_content_type :upload, content_type: ['application/pdf', 'image/gif', 'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png', 'text/html', 'video/mp4', 'video/quicktime']
  validates_attachment_size :upload, less_than: CONTENT_MAX_FILE_SIZE.megabytes
  belongs_to :content, touch: true
  has_many :stickies, as: :target, dependent: :destroy
  validates_presence_of :content_id
  validates_presence_of :upload_file_name, if: "category == 'file'"
  validates_inclusion_of :category, in: %w[file cover assignment]
  validates_uniqueness_of :category, scope: [:content_id], if: "category == 'cover'"
  validates_uniqueness_of :category, scope: [:content_id], if: "category == 'assignment'"
  validates_uniqueness_of :upload_file_name, scope: [:content_id], if: "category == 'file'"
  validates_numericality_of :display_order, equal_to: 0, if: "category == 'cover'"
  validates_numericality_of :display_order, greater_than: 0, if: "category != 'cover'"
end

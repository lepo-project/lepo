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
  # FIXME: Paperclip2shrine
  # has_attached_file :upload

  belongs_to :snippet, touch: true
  validates_presence_of :snippet_id
  validates_presence_of :upload_file_name
  validates_uniqueness_of :snippet_id

  # ====================================================================
  # Public Functions
  # ====================================================================
end

# == Schema Information
#
# Table name: outcome_files
#
#  id                  :integer          not null, primary key
#  outcome_id          :integer
#  upload_file_name    :string
#  upload_content_type :string
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  upload_data         :string
#

require 'json'
class OutcomeFile < ApplicationRecord
  include OutcomeUploader::Attachment.new(:upload)
  # FIXME: Paperclip2shrine
  has_attached_file :upload

  belongs_to :outcome, touch: true
  validates_presence_of :outcome_id

  def file_name
    JSON.parse(self.upload_data)['metadata']['filename'] if self.upload_data
  end

  def same_name_file
    files = OutcomeFile.where(outcome_id: outcome_id)
    files.each do |f|
      return f if f.file_name == file_name
    end
    nil
  end

  def upload_rails_url
    "/outcome_files/#{id}/upload" if upload
  end
end

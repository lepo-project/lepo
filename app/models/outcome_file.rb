# == Schema Information
#
# Table name: outcome_files
#
#  id          :integer          not null, primary key
#  outcome_id  :integer
#  upload_data :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'json'
class OutcomeFile < ApplicationRecord
  include OutcomeUploader::Attachment.new(:upload)
  belongs_to :outcome, touch: true
  validates :outcome_id, presence: true
  validates :upload_data, presence: true

  def file_name
    JSON.parse(upload_data)['metadata']['filename'] if upload_data
  end

  def same_name_file
    files = OutcomeFile.where(outcome_id: outcome_id)
    files.each do |f|
      return f if f.file_name == file_name
    end
    nil
  end

  def upload_id
    outcome.folder_name
  end

  def upload_rails_url
    "#{Rails.application.config.relative_url_root}/outcome_files/#{id}/upload?folder_id=#{upload_id}" if upload
  end
end

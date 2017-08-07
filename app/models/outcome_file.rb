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
#

class OutcomeFile < ApplicationRecord
  has_attached_file :upload,
                    path: ':rails_root/public/system/users/:outcome_manager_folder_id/assignment_outcomes/:outcome_folder_id/:filename',
                    url: ':relative_url_root/system/users/:outcome_manager_folder_id/assignment_outcomes/:outcome_folder_id/:filename'
  validates_attachment_size :upload, less_than: OUTCOME_MAX_FILE_SIZE.megabytes
  do_not_validate_attachment_file_type :upload
  belongs_to :outcome, touch: true
  validates_presence_of :outcome_id
  validates_presence_of :upload_file_name
  validates_uniqueness_of :upload_file_name, scope: [:outcome_id]
end

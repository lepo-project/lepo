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

FactoryGirl.define do
  factory :outcome_file do
    association :outcome
    sequence(:upload_file_name) { |i| "UploadFile#{i}" }
  end
end

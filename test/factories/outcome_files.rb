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

FactoryBot.define do
  factory :outcome_file do
    association :outcome
    upload_data 'upload file data by JSON format'
  end
end

# == Schema Information
#
# Table name: asset_files
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

FactoryBot.define do
  factory :asset_file do
    association :content
    sequence(:upload_file_name) { |i| "UploadFile#{i}" }
  end
end

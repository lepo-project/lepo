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

FactoryGirl.define do
  factory :snippet_file do
    sequence(:snippet_id) { |i| i }
    sequence(:upload_file_name) { |i| "UploadFile#{i}" }
  end
end

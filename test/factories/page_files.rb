# == Schema Information
#
# Table name: page_files
#
#  id                  :integer          not null, primary key
#  content_id          :integer
#  display_order       :integer
#  upload_file_name    :string
#  upload_content_type :string
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

FactoryGirl.define do
  factory :page_file do
    sequence(:content_id) { |i| i }
    sequence(:upload_file_name) { |i| "UploadFile#{i}" }
  end
end

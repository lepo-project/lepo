# == Schema Information
#
# Table name: page_files
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

FactoryBot.define do
  factory :page_file do
    association :content
    sequence(:upload_file_name) { |i| "UploadFile#{i}" }

    factory :page_cover do
      category 'cover'
      upload_file_name nil
    end

    factory :page_assignment do
      category 'assignment'
      upload_file_name nil
    end
  end
end

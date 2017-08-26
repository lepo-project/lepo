# == Schema Information
#
# Table name: courses
#
#  id                 :integer          not null, primary key
#  term_id            :integer
#  folder_id          :string
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  title              :string
#  overview           :text
#  status             :string           default("draft")
#  groups_count       :integer          default(1)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :course do
    association :term
    sequence(:title) { |i| "Course #{i} Title" }
    overview 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '

    factory :open_course do
      status 'open'
    end

    factory :archived_course do
      status 'archived'
    end
  end
end

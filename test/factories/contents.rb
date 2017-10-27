# == Schema Information
#
# Table name: contents
#
#  id          :integer          not null, primary key
#  category    :string
#  folder_name :string
#  title       :string
#  condition   :text
#  overview    :text
#  status      :string           default("open")
#  as_category :string           default("text")
#  as_overview :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :content, class: Content do
    category 'upload'
    sequence(:title) { |i| "Content #{i} Title" }
    condition 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    overview 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    as_overview 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '

    factory :content_with_file_assignment do
      as_category 'file'
    end

    factory :content_with_outside_assignment do
      as_category 'outside'
    end

    factory :archived_content do
      status 'archived'
    end
  end
end

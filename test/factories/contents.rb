# == Schema Information
#
# Table name: contents
#
#  id          :integer          not null, primary key
#  category    :string
#  folder_id   :string
#  title       :string
#  condition   :text
#  overview    :text
#  status      :string           default("open")
#  as_category :string           default("text")
#  as_overview :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :content do
    category 'upload'
    sequence(:title) { |i| "Content #{i} Title" }
    condition 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    overview 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    as_overview 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
  end
end

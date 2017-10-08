# == Schema Information
#
# Table name: bookmarks
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  display_order :integer
#  url           :text
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :bookmark do
    association :manager, factory: :user
    sequence(:display_order) { |i| i }
    url { 'http://' + (1..10).map { ('a'..'z').to_a[rand(26)] }.join }
    sequence(:title) { |i| "bookmark #{i} Title" }
  end
end

# == Schema Information
#
# Table name: links
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
  factory :link do
    sequence(:manager_id) { |i| i }
    sequence(:display_order) { |i| i }
    url { 'http://' + (1..10).map { ('a'..'z').to_a[rand(26)] }.join }
    sequence(:title) { |i| "Link #{i} Title" }
  end
end

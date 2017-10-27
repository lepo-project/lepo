# == Schema Information
#
# Table name: web_pages
#
#  id         :integer          not null, primary key
#  url        :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :web_page do
    url { 'http://' + (1..10).map { ('a'..'z').to_a[rand(26)] }.join }
    sequence(:title) { |i| "Web Source #{i} Title" }
  end
end

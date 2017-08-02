# == Schema Information
#
# Table name: web_sources
#
#  id         :integer          not null, primary key
#  url        :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :web_source do
    url { 'http://' + (1..10).map { ('a'..'z').to_a[rand(26)] }.join }
    sequence(:title) { |i| "Web Source #{i} Title" }
  end
end

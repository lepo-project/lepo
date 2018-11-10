# == Schema Information
#
# Table name: bookmarks
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  display_order :integer
#  display_title :string
#  target_id     :integer
#  target_type   :string           default("web")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :bookmark do
    association :manager, factory: :user
    association :target, factory: :web_page
    sequence(:display_order) { |i| i }
    sequence(:display_title) { |i| "bookmark #{i} Title" }
  end
end

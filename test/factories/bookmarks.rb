# == Schema Information
#
# Table name: bookmarks
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  display_order :integer
#  display_title :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  target_id     :integer
#  target_type   :string           default("web")
#

FactoryBot.define do
  factory :bookmark do
    association :manager, factory: :user
    association :target, factory: :web_page
    sequence(:display_order) { |i| i }
    sequence(:display_title) { |i| "bookmark #{i} Title" }
  end
end

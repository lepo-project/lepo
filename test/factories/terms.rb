# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  sourced_id :string
#  title      :string
#  start_at   :datetime
#  end_at     :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :term do
    sequence(:sourced_id) { |i| "dummy-term-sourced_id-#{i}" }
    sequence(:title) { |i| "Term #{i} Title" }
    start_at Date.today
    end_at Date.today + 6.months
  end
end

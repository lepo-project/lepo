# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  title      :string
#  start_at   :date
#  end_at     :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :term do
    sequence(:title) { |i| "Term #{i} Title" }
    start_at Date.today
    end_at Date.today + 6.months
  end
end

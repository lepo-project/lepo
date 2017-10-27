# == Schema Information
#
# Table name: outcome_messages
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  outcome_id :integer
#  message    :text
#  score      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :outcome_message do
    association :manager, factory: :user
    association :outcome
    sequence(:message) { |i| "Outcome Message #{i}" }
    score 10
  end
end

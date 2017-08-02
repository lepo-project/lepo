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

FactoryGirl.define do
  factory :outcome_message do
    sequence(:manager_id) { |i| i }
    sequence(:outcome_id) { |i| i }
    sequence(:message) { |i| "Outcome Message #{i}" }
    score 10
  end
end

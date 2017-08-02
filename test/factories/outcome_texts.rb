# == Schema Information
#
# Table name: outcome_texts
#
#  id         :integer          not null, primary key
#  outcome_id :integer
#  entry      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :outcome_text do
    sequence(:outcome_id) { |i| i }
    entry 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
  end
end

# == Schema Information
#
# Table name: snippets
#
#  id            :integer          not null, primary key
#  manager_id    :integer
#  note_id       :integer
#  category      :string           default("text")
#  description   :text
#  source_type   :string           default("direct")
#  source_id     :integer
#  master_id     :integer
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :snippet do
    sequence(:manager_id) { |i| i }
    sequence(:note_id) { |i| i }
    description 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    sequence(:source_id) { |i| i }
    sequence(:master_id) { |i| i }
    sequence(:display_order) { |i| i }
  end
end

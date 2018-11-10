# == Schema Information
#
# Table name: note_indices
#
#  id            :integer          not null, primary key
#  note_id       :integer
#  item_id       :integer
#  item_type     :string           default("Snippet")
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :note_index do
    association :note
    association :item, factory: :snippet
    sequence(:display_order) { |i| i }
  end
end

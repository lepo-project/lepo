# == Schema Information
#
# Table name: note_indices
#
#  id            :integer          not null, primary key
#  note_id       :integer
#  snippet_id    :integer
#  display_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :note_index do
    association :note
    association :snippet
    sequence(:display_order) { |i| i }
  end
end

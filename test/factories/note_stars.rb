# == Schema Information
#
# Table name: note_stars
#
#  id         :integer          not null, primary key
#  manager_id :integer
#  note_id    :integer
#  stared     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :note_star do
    association :manager, factory: :user
    association :note
  end
end

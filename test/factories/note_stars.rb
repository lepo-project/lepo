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

FactoryGirl.define do
  factory :note_star do
    sequence(:manager_id) { |i| i }
    sequence(:note_id) { |i| i }
  end
end
